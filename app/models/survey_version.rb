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
  has_many :pages, :autosave => true
  has_many :survey_elements
  
  attr_accessible :major, :minor, :published, :notes
  
  validates :major, :presence => true, :numericality => true
  validates :minor, :presence => true, :numericality => true
  validates :notes, :length => {:maximum => 65535}
  
  # Scopes for partitioning survey versions
  scope :published, where(:published => true)
  
  # Add methods to access the name and description of a survey from a version instance
  # survey_version.survey_name
  # survey_version.survey_description
  delegate :name, :description, :to => :survey, :prefix => true
  
  def next_page_number
    self.pages.count + 1
  end
end
