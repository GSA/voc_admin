# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# An Asset is an HTML Snippet survey element.
class Asset < ActiveRecord::Base
  has_one :survey_element, :as => :assetable, :dependent => :destroy

  attr_accessible :survey_element_attributes, :snippet
  accepts_nested_attributes_for :survey_element

  validates :snippet, :presence => true

  # There is no associated Answer, so it's never required
  #
  # @return [false]
  def required
    false
  end

  # Aliases the "snippet" field to "statement".
  def statement
    self.snippet
  end

  # Questionable type.
  def answer_type
    "HTML snippet"
  end

  # Duplicates the Asset upon cloning a SurveyVersion.
  #
  # @param [SurveyVersion] target_sv the SurveyVersion destination for the new cloned copy
  # @return [Asset] the cloned Asset
  def clone_me(target_sv)
    se_attribs = self.survey_element.attributes.merge(
      :survey_version_id=>target_sv.id,
      :page_id=>(target_sv.pages.find_by_clone_of_id(self.survey_element.page_id).id))
    se_attribs.delete("id")
    Asset.create!(self.attributes.except("created_at", "updated_at").merge("survey_element_attributes"=>se_attribs))
  end

  # Duplicates the Asset upon cloning the Page.
  #
  # @param [Page] page the Page destination for the new cloned copy
  # @return [Asset] the newly-copied Asset
  def copy_to_page(page)
    se_attribs = self.survey_element.attributes
      .except("id", "created_at", "updated_at")
      .merge(:page_id=>page.id)
    Asset.create!(self.attributes
      .except("id", "created_at", "updated_at")
      .merge(:survey_element_attributes=>se_attribs)
    )
  end

  def reporter
    nil
  end

  def describe_me(assetable_type, element_order)
    {
      id: id,
      assetable_type: assetable_type,
      element_order: element_order,
      snippet: snippet
    }.reject {|k, v| v.blank? }
  end
end

# == Schema Information
#
# Table name: assets
#
#  id         :integer          not null, primary key
#  snippet    :text
#  created_at :datetime
#  updated_at :datetime
#

