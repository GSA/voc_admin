# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Represents a visit count on a date for a survey version.
class SurveyVisitCount < ActiveRecord::Base
  belongs_to :survey_version
end

# == Schema Information
#
# Table name: survey_visit_counts
#
#  id                :integer(4)      not null, primary key
#  survey_version_id :integer(4)
#  visit_date        :date
#  visits            :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
