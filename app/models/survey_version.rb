# == Schema Information
# Schema version: 20110406195219
#
# Table name: survey_versions
#
#  id         :integer(4)      not null, primary key
#  survey_id  :integer(4)
#  major      :integer(4)
#  minor      :integer(4)
#  published  :boolean(1)
#  notes      :text
#  created_at :datetime
#  updated_at :datetime
#

class SurveyVersion < ActiveRecord::Base
  belongs_to :survey
  
  attr_accessible :major, :minor, :published, :notes
  
  validates :major, :presence => true, :numericality => true
  validates :minor, :presence => true, :numericality => true
  validates :notes, :length => {:maximum => 65535}
  
  
end
