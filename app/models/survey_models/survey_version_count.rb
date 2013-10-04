# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Represents a visit count on a date for a survey version.
class SurveyVersionCount < ActiveRecord::Base
  belongs_to :survey_version

  def self.visit_count_for_date_range(start_date, end_date)
    for_date_range(start_date, end_date).sum(:visits)
  end

  def self.questions_skipped_for_date_range(start_date, end_date)
    for_date_range(start_date, end_date).sum(:questions_skipped)
  end

  def self.questions_asked_for_date_range(start_date, end_date)
    for_date_range(start_date, end_date).sum(:questions_asked)
  end

  def self.for_date_range(start_date, end_date)
    start_date = start_date.to_date unless start_date.is_a?(String)
    end_date = end_date.to_date unless end_date.is_a?(String)
    where(:count_date => start_date..end_date)
  end
end

# == Schema Information
#
# Table name: survey_version_counts
#
#  id                :integer(4)      not null, primary key
#  survey_version_id :integer(4)
#  count_date        :date
#  visits            :integer(4)      default(0)
#  questions_skipped :integer(4)      default(0)
#  questions_asked   :integer(4)      default(0)
#  created_at        :datetime
#  updated_at        :datetime
