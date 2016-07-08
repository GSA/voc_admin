# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# A single survey element (currently: TextQuestion, ChoiceQuestion, MatrixQuestion, Asset)
# which exists on a Page within a SurveyVersion.
class SurveyElement < ActiveRecord::Base
  belongs_to :page
  belongs_to :assetable, :polymorphic => true#, :dependent => :destroy
  belongs_to :survey_version, :touch => true
  has_many :dashboard_elements, :dependent => :destroy

  attr_accessor :skip_callbacks

  # If this is not a clone operation, sets element order. This is because cloning
  # already has element orders set, and element clone order is non deterministic.
  #
  # Triggered through accepts_nested_attributes_for on the individual survey element type ("caller").
  before_validation :set_element_order, :on => :create, :if =>  Proc.new {|object|
    # test the caller's member objects to ensure this isn't a clone operation
    caller.inject(true) {|test, caller_member| test && !caller_member.include?("clone_me")}
  }

  # Moving a SurveyElement between Pages from the edit view will always append
  # the SurveyElement to the destination page.  Using the move up / move down arrows
  # in the SurveyVersion edit view can move from the end of one Page to the beginning
  # of another.
  before_validation :move_to_end_of_page, :on => :update, :if => Proc.new {|object|
    object.page_id_changed? && !object.skip_callbacks
  }

  validates :element_order, :presence => true, :numericality => true, :uniqueness => {:scope => [:page_id]}
  validates :page, :presence => true
  validates :survey_version, :presence => true

  after_destroy :reorder_page_elements_on_destroy
  after_save :update_survey_version_updated_at

  default_scope  { order(:element_order) }
  scope :questions, -> {
    where('survey_elements.assetable_type in (?)',
          %w(TextQuestion ChoiceQuestion MatrixQuestion))
    .includes(:assetable => :question_content)
  }
  scope :assets, -> {
    where('survey_elements.assetable_type in (?)', %w(Asset)).includes(:assetable)
  }

  delegate :reporter, to: :assetable

  # Sets the SurveyVersion update timestamp whenever changes are made to a contained SurveyElement.
  def update_survey_version_updated_at
    self.survey_version.update_attribute(:updated_at, Time.now)
  end

  # Cleans up gaps in element order when the SurveyElement is moved to another Page or destroyed.
  #
  # @param [Page] page the Page that the SurveyElement is removed from
  def self.compact_element_order(page)
    page.survey_elements.order(:element_order).each_with_index do |se, index|
      se.update_attribute(:element_order, index + 1)
    end
  end

  # Moves a SurveyElement to the end of its Page.
  #
  # @return [false, Integer] false if no Page association exists, otherwise the determined element order
  def move_to_end_of_page
    return false if self.page_id.nil?
    self.element_order = Page.find(self.page_id).survey_elements.maximum(:element_order).to_i + 1
  end

  # Moves the element from any source Page to any destination Page, optionally specifying
  # an element order position.  Note: source and destination Pages may be the same.
  #
  # @param [Integer] page_num the destination Page id
  # @param [Integer] new_element_order an optional new element order
  def move_element(page_num, new_element_order = nil)
    SurveyElement.transaction do

      # slightly different logic if on same page
      if self.page.page_number == page_num

        # make sure we are actually moving something
        return if new_element_order == self.element_order

        start_index, end_index = new_element_order < self.element_order ? [new_element_order,self.element_order] : [self.element_order,new_element_order]

        # shift range from target to source (overright source with it's neighbor in direction of target)
        if new_element_order < self.element_order
          self.page.survey_elements.where(['element_order >= ? and element_order < ?', start_index, end_index]).update_all("element_order = element_order + 1")
        else
          self.page.survey_elements.where(['element_order > ? and element_order <= ?', start_index, end_index]).update_all("element_order = element_order - 1")
        end

        # update source to target
        self.update_attribute(:element_order, new_element_order)
      else
        originating_page = self.page # will need this for clean up

        # remove flow control from ChoiceQuestion answer sets
        if self.assetable_type == "ChoiceQuestion"
          self.assetable.choice_answers.update_all(['next_page_id = ?', nil])
          self.assetable.question_content.update_attribute(:flow_control, false)
        end

        # shift the element to new page (insert or append)
        if new_element_order
          # insert: move everything up one place after where we want to insert the element
          self.survey_version.pages.find_by_page_number(page_num).survey_elements.where(['element_order >= ?', new_element_order]).update_all("element_order = element_order + 1")

          # insert the element, skipping move_to_end_of_page validation
          self.update_attributes(:page_id => self.survey_version.pages.find_by_page_number(page_num).id,
                                 :element_order => new_element_order,
                                 :skip_callbacks => true)
        else
          # append: append the element, skipping move_to_end_of_page validation
          self.update_attributes(:page_id => self.survey_version.pages.find_by_page_number(page_num).id,
                                 :element_order => (self.survey_version.pages.find_by_page_number(page_num).survey_elements.maximum(:element_order).to_i + 1),
                                 :skip_callbacks => true)
        end

        # clean up the original page (would have gap left by moving element
        SurveyElement.compact_element_order(originating_page)
      end
    end
  end

  # Moves the SurveyElement to the next element order (same page) or the next page
  # if it's already the last SurveyElement on the page.
  def move_element_down
    target_page_num,target_element = (self.element_order + 1) > self.page.survey_elements.maximum(:element_order).to_i  ?
      [self.page.page_number + 1, 1] :
      [self.page.page_number, self.element_order + 1]

    # is target page valid?
    return if target_page_num > self.survey_version.pages.maximum(:page_number).to_i

    self.move_element(target_page_num, target_element)
  end

  # Moves the SurveyElement to the previous element order (same page) or the previous page
  # if it's already the first SurveyElement on the page.
  def move_element_up
    target_page_num,target_element = self.element_order.to_i == 1 ?
      [self.page.page_number - 1, nil] :
      [self.page.page_number, self.element_order - 1]

    # is target page valid?
    return if target_page_num < 1

    self.move_element(target_page_num, target_element)
  end

  # Clone the SurveyElement, delegating the real work to the specific
  # SurveyElement type. Used when cloning a SurveyVersion.
  #
  # @param [SurveyVersion] target_sv the target SurveyVersion
  # @return [SurveyElement] the cloned copy
  def clone_me(target_sv)
    cloned_assetable = self.assetable.clone_me(target_sv)
    cloned_assetable.survey_element
  end

  # Copy the SurveyElement to a specified Page, delegating the real work
  # to the specific SurveyElement type.
  #
  # @param [Page] page the target Page
  # @return [SurveyElement] the cloned copy
  def copy_to_page(page)
    copy_of_assetable = self.assetable.copy_to_page(page)
    copy_of_assetable.survey_element
  end

  def describe_me
    assetable.describe_me(assetable_type, element_order)
  end

  private

  # On create validation, sets the order of an added SurveyElement; refactors
  # the element order of all subsequent SurveyElements across pages as necessary.
  def set_element_order
    if self.new_record?
      return false unless self.page && self.survey_version

      new_element_order = self.survey_version.survey_elements.includes(:page)
        .where(:pages => { :page_number => page.page_number })
        .maximum(:element_order).to_i + 1

      self.survey_version.survey_elements
        .where([
          'survey_elements.element_order >= ? and page_id = ?',
          new_element_order, page.id])
        .update_all(
        'survey_elements.element_order = survey_elements.element_order + 1',
      )
      self.element_order = new_element_order

    end
  end

  # Hook used to clean up element order upon SurveyElement destruction.
  def reorder_page_elements_on_destroy
    SurveyElement.compact_element_order(self.page)
  end

end

# == Schema Information
#
# Table name: survey_elements
#
#  id                :integer          not null, primary key
#  page_id           :integer
#  element_order     :integer
#  assetable_id      :integer
#  assetable_type    :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  survey_version_id :integer
#

