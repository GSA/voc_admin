# == Schema Information
# Schema version: 20110406195219
#
# Table name: surveys
#
#  id             :integer(4)      not null, primary key
#  name           :string(255)
#  description    :text
#  survey_type_id :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

class Survey < ActiveRecord::Base
  has_many :survey_versions
  belongs_to :survey_type
  
  attr_accessible :name, :description  
  
  validates :name, :presence => true, :length => {:in => 1..255}
  validates :description, :presence => true, :length => {:in => 1..65535}
  validates :survey_versions, :presence => true
  
  def newest_version
    self.survey_versions.order('major desc, minor desc').first
  end
end
