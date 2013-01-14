# == Schema Information
# Schema version: 20110413183938
#
# Table name: survey_elements
#
#  id                :integer(4)      not null, primary key
#  page_id           :integer(4)
#  element_order     :integer(4)
#  assetable_id      :integer(4)
#  assetable_type    :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  survey_version_id :integer(4)
#

class SurveyElement < ActiveRecord::Base
  belongs_to :page
  belongs_to :assetable, :polymorphic => true, :dependent => :destroy
  belongs_to :survey_version, :touch => true

  attr_accessor :skip_callbacks

  ## Validations
  before_validation :set_element_order, :on => :create, :if=> Proc.new {|object|
    test = true
    caller.each do |caller_member|
      test = test && (!caller_member.include?("clone_me"))
    end
    test
  }

  ## Why is this here?
  before_validation :move_to_end_of_page, :on => :update, :if => Proc.new {|object|
    object.page_id_changed? && !object.skip_callbacks
  }

  validates :element_order, :presence => true, :numericality => true, :uniqueness => {:scope => [:page_id]}
  validates :page, :presence => true
  validates :survey_version, :presence => true

  ## Callbacks
  after_destroy :reorder_page_elements_on_destroy
  after_save :update_survey_version_updated_at

  ## Scopes
  default_scope order(:element_order)
  scope :questions, where('survey_elements.assetable_type in (?)', %w(TextQuestion ChoiceQuestion MatrixQuestion)).includes(:assetable => :question_content)
  scope :assets, where('survey_elements.assetable_type in (?)', %w(Asset)).includes(:assetable)

  # when any changes are made to a survey element mark the survey version as being updated
  def update_survey_version_updated_at
    self.survey_version.update_attribute(:updated_at, Time.now)
  end

  #used to clean up gaps in element order when question is moved to another page or destroyed
  def self.compact_element_order(page)
    page.survey_elements.order(:element_order).each_with_index do |se, index|
      se.update_attribute(:element_order, index+1)
    end
  end

  def move_to_end_of_page
    return false if self.page_id.nil?
    self.element_order = Page.find(self.page_id).survey_elements.maximum(:element_order).to_i + 1
  end

  #move any element from any page to another page at any position (TODO: protect flow control)
  def move_element(page_num, new_element_order=nil)
    SurveyElement.transaction do
      #slightly different logic if on same page
      if self.page.page_number == page_num
        #make sure we are actually moving something
        return if new_element_order == self.element_order
        start_index, end_index = new_element_order < self.element_order ? [new_element_order,self.element_order] : [self.element_order,new_element_order]

        #shift range from target to source (overright source with it's neighbor in direction of target)
        if new_element_order < self.element_order
          self.page.survey_elements.where(['element_order >= ? and element_order < ?', start_index, end_index]).update_all("element_order = element_order + 1")
        else
          self.page.survey_elements.where(['element_order > ? and element_order <= ?', start_index, end_index]).update_all("element_order = element_order - 1")
        end

        #update source to target
        self.update_attribute(:element_order, new_element_order)
      else
        orginating_page = self.page #will need this for clean up

        #remove flow control from ChoiceQuestion answer sets
        if self.assetable_type == "ChoiceQuestion"
          self.assetable.choice_answers.update_all(['next_page_id = ?', nil])
          self.assetable.question_content.update_attribute(:flow_control, false)
        end

        #shift the element to new page (insert or append)
        if new_element_order

          #move everything up one place after where we want to insert the element
          self.survey_version.pages.find_by_page_number(page_num).survey_elements.where(['element_order >= ?', new_element_order]).update_all("element_order = element_order + 1")
          #insert the element
          self.update_attributes(:page_id=>self.survey_version.pages.find_by_page_number(page_num).id, :element_order=>new_element_order, :skip_callbacks => true)
        else
          #append
          self.update_attributes(:page_id=>self.survey_version.pages.find_by_page_number(page_num).id, :element_order=>(self.survey_version.pages.find_by_page_number(page_num).survey_elements.maximum(:element_order).to_i + 1), :skip_callbacks => true)
        end


        #clean up the original page (would have gap left by moving element
        SurveyElement.compact_element_order(orginating_page)
      end
    end
  end

  #moves to next element order or next page if necessary and possible
  def move_element_down
    target_page_num,target_element = (self.element_order + 1) > self.page.survey_elements.maximum(:element_order).to_i  ?
      [self.page.page_number + 1, 1] :
      [self.page.page_number, self.element_order + 1]

    #is target page valid?
    return if target_page_num > self.survey_version.pages.maximum(:page_number).to_i

    self.move_element(target_page_num, target_element)

  end

  #moves to prior element order or prior page if necessary and possible
  def move_element_up
    target_page_num,target_element = self.element_order.to_i == 1 ?
      [self.page.page_number - 1, nil] :
      [self.page.page_number, self.element_order - 1]

    #is target page valid
    return if target_page_num < 1

    self.move_element(target_page_num, target_element)
  end

  def clone_me(target_sv)
    cloned_assetable = self.assetable.clone_me(target_sv)
    cloned_assetable.survey_element
  end

  def copy_to_page(page)
    copy_of_assetable = self.assetable.copy_to_page(page)
    copy_of_assetable.survey_element
  end

  private
  def set_element_order
    if self.new_record?
      return false unless self.page && self.survey_version
      new_element_order = self.survey_version.survey_elements.includes(:page).where('pages.page_number <= ?', self.page.page_number).maximum(:element_order).to_i + 1
      self.survey_version.survey_elements.update_all('survey_elements.element_order = survey_elements.element_order + 1', ['survey_elements.element_order >= ?', new_element_order])
      self.element_order = new_element_order
    end
  end

  def reorder_page_elements_on_destroy
    SurveyElement.compact_element_order(self.page)
  end

end
