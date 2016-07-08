# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# There are three distinct types of surveys that may be created: Site, Page, and Poll.
class SurveyType < ActiveRecord::Base
  has_many :surveys

  validates :name, :presence => true, :length => {:in => 1..255}, :uniqueness => true

  # All question types are available. Intended to be used once on a site and serve
  # as a comprehensive survey.
  SITE = 1

  # Matrix questions are not allowed. Intended for use on individual pages and
  # collect 1-3 data points.
  PAGE = 2

  # Matrix questions are not allowed. Displays a tally of collected results upon submit.
  POLL = 3

  # Return the name from survey_type with the name field capitalized.
  #
  # @return [String] the capitalized name
  def name_upcase
    self.name.capitalize
  end
end

# == Schema Information
#
# Table name: survey_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

