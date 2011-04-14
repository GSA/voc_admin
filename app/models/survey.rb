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
  has_many :survey_versions, :dependent => :destroy
  belongs_to :survey_type
  
  attr_accessible :name, :description  
  
  validates :name, :presence => true, :length => {:in => 1..255}, :uniqueness => true
  validates :description, :presence => true, :length => {:in => 1..65535}
  
  def newest_version
    self.survey_versions.order('major desc, minor desc').first
  end
end
