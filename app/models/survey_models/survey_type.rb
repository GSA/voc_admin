# == Schema Information
# Schema version: 20110408150334
#
# Table name: survey_types
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class SurveyType < ActiveRecord::Base
  has_many :surveys

  validates :name, :presence => true, :length => {:in => 1..255}, :uniqueness => true

  SITE = 1
  PAGE = 2
  POLL = 3

  def name_upcase
    self.name.capitalize
  end
end