class SurveyVersions < ActiveRecord::Base
  belongs_to :survey
  
  attr_accessible :major, :minor, :published, :notes
  
  validates :major, :presence => true, :numericality => true
  validates :minor, :presence => true, :numericality => true
  validates :notes, :length => {:in => 1..65535}
  
  
end
