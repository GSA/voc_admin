# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# ExectionTriggers represent the SurveyResponse events which should
# activate a given Rule.
class ExecutionTrigger < ActiveRecord::Base

  # On creation of a new SurveyResponse record
  ADD = 1
  # On update of a SurveyResponse record
  UPDATE = 2
  # On delete of a SurveyResponse record
  DELETE = 3
  # As part of the nightly Rules execution - UNSUPPORTED, WILL NOT RUN
  NIGHTLY = 4

  validates :name, :presence => true, :uniqueness => true
end

# == Schema Information
#
# Table name: execution_triggers
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

