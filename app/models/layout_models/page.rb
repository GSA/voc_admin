# == Schema Information
#
# Table name: pages
#
#  id                :integer          not null, primary key
#  page_number       :integer
#  survey_version_id :integer
#  style_id          :integer
#  created_at        :datetime
#  updated_at        :datetime
#  clone_of_id       :integer
#  next_page_id      :integer
#

# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# A Page is a container for one screen's worth of SurveyElements.
class Page < ActiveRecord::Base
  belongs_to :survey_version, :touch => true
  has_many :survey_elements, :dependent => :destroy

  belongs_to :next_page, :foreign_key => :next_page_id, :class_name => "Page", :inverse_of => :prev_pages
  has_many :prev_pages, :foreign_key => :next_page_id, :class_name => "Page", :inverse_of => :next_page

  before_destroy :renumber_pages

  validates :page_number, :presence => true, :numericality => true, :uniqueness => {:scope => :survey_version_id}
  validates :survey_version, :presence => true
  validate :next_page_greater_than_current_page

  # The next page in the survey, either by explicit flow control or incrementing current page number
  # 
  # @return [Page,nil] the next page in the survey or nil if this is the last page
  def next_page_with_page_id
    if self.next_page_id.nil?
      Page.where(:survey_version_id => self.survey_version).find_by_page_number(self.page_number + 1)
    else
      next_page_without_page_id
    end
  end

  alias_method_chain :next_page, :page_id

  # Find the previous page (does not take flow control into consideration as this is managed via JavaScript)
  # 
  # @return [Page,nil] the previous page in the survey or nil if this is the first page
  def prev_page
    self.survey_version.pages.where(:page_number => (self.page_number - 1)).first
  end

  # Reorder pages. Contains logic for bounds checking and tries to ensure
  # that flow control does not create a loop.
  # 
  # @param [Integer] target_page_number the destination page number
  def move_page_to(target_page_number)
    # Page number cannot be <= 0 or > number of total pages
    return if target_page_number.to_i <= 0 || target_page_number.to_i > self.survey_version.pages.count
    current_page_number = self.page_number

    # if the page has flow control, you cannot move the page to a higher page number than the target.
    # This would allow the user to possibly cause a loop
    if (self.next_page_id.present? && (self.next_page.page_number <= target_page_number.to_i)) || (self.prev_pages.any? {|page| target_page_number.to_i < current_page_number && page.page_number >= target_page_number.to_i})
      self.errors.add(:base, "Moving page would break flow control.  Please remove flow control from the page and try again.")
      return false
    end

    if current_page_number > target_page_number.to_i
      # 1 2 3 target_page_number  5 6 current_page_number
      self.survey_version.pages.update_all('pages.page_number = pages.page_number + 1', ['pages.page_number >= ? AND pages.page_number < ?', target_page_number, current_page_number])
    else
      # 1 2 3 current_page_number 5 6 target_page_number
      self.survey_version.pages.update_all('pages.page_number = pages.page_number - 1', ['pages.page_number > ? AND pages.page_number <= ?', current_page_number, target_page_number])
    end

    self.update_attribute(:page_number, target_page_number)
  end

  # Duplicates the Page upon cloning a SurveyVersion.
  # 
  # @param [SurveyVersion] target_sv the SurveyVersion destination for the new cloned copy
  # @return [Page] the cloned page
  def clone_me(target_sv)
    new_page = Page.create!(self.attributes.merge(:survey_version=>target_sv, :clone_of_id => self.id))
  end

  # Duplicates the Page and all contained SurveyElements
  # 
  # @return [Page] the duplicated page
  def create_copy
    #add page at end of survey
    new_page_num = self.survey_version.pages.size + 1
    page_attribs = self.attributes.merge(:page_number => new_page_num)
    page_attribs.delete("id")
    page_attribs.delete("next_page_id")
    new_page = Page.create!(page_attribs)

    #Copy current page assetables
    SurveyElement.find_all_by_survey_version_id_and_page_id(survey_version_id , self.id).each do |se|
      se.copy_to_page(new_page)
    end

    new_page
  end

  private
  # Validation to help prevent cyclical references in flow control
  def next_page_greater_than_current_page
    self.errors.add(:next_page, "Next page must come after the current page.") if self.next_page_id.present? && self.next_page.page_number < self.page_number
  end

  # Ensures that successive pages are renumbered properly on page destroy
  def renumber_pages
    self.survey_version.pages.update_all('pages.page_number = pages.page_number - 1', ['page_number > ?', self.page_number])
  end

end

# == Schema Information
#
# Table name: pages
#
#  id                :integer(4)      not null, primary key
#  page_number       :integer(4)
#  survey_version_id :integer(4)
#  style_id          :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#  clone_of_id       :integer(4)
#  next_page_id      :integer(4)
#
