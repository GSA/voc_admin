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
  belongs_to :assetable, :polymorphic => true
  belongs_to :survey_version
  
  validates :element_order, :presence => true, :numericality => true, :uniqueness => {:scope => [:page_id]}

  def previous_element
    self.element_order == 1 ? nil : self.survey_version.survey_elements.where(:element_order => (self.element_order - 1)).first 
  end
  
  def next_element
    self.element_order == self.survey_version.survey_elements.count ? nil : self.survey_version.survey_elements.where(:element_order => (self.element_order + 1)).first
  end

  def move_element_up
    prev = self.previous_element
    
    unless prev.nil?
      self.element_order = prev.element_order
      prev.element_order = prev.element_order + 1
      self.save
      prev.save
    end
  end
  
end
