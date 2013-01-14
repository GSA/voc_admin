# == Schema Information
# Schema version: 20110415192145
#
# Table name: assets
#
#  id         :integer(4)      not null, primary key
#  snippet    :text
#  created_at :datetime
#  updated_at :datetime
#

class Asset < ActiveRecord::Base
  has_one :survey_element, :as => :assetable, :dependent => :destroy

  attr_accessible :survey_element_attributes, :snippet
  accepts_nested_attributes_for :survey_element

  validates :snippet, :presence => true

  def required
    false
  end

  def statement
    self.snippet
  end

  def answer_type
    "HTML snippet"
  end

  def clone_me(target_sv)
    se_attribs = self.survey_element.attributes.merge(
      :survey_version_id=>target_sv.id,
      :page_id=>(target_sv.pages.find_by_clone_of_id(self.survey_element.page_id).id))
    se_attribs.delete("id")
    Asset.create!(self.attributes.except("created_at", "updated_at").merge("survey_element_attributes"=>se_attribs))
  end

  def copy_to_page(page)
    se_attribs = self.survey_element.attributes.merge(:page_id=>page.id)
    se_attribs.delete("id")
    Asset.create!(self.attributes.merge(:survey_element_attributes=>se_attribs))
  end
end
