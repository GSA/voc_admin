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
  
  validates :element_order, :presence => true, :numericality => true
end
