# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Represents a visit count on a date for a survey version.
class SurveyVersionCount < ActiveRecord::Base
  belongs_to :survey_version

  def self.visit_count_for_date_range(start_date, end_date)
    for_date_range(start_date, end_date).sum(:visits)
  end

  def self.invitation_count_for_date_range(start_date, end_date)
    for_date_range(start_date, end_date).sum(:invitations)
  end

  def self.invitation_accepted_count_for_date_range(start_date, end_date)
    for_date_range(start_date, end_date).sum(:invitations_accepted)
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
#  id                   :integer          not null, primary key
#  survey_version_id    :integer
#  count_date           :date
#  visits               :integer          default(0)
#  created_at           :datetime
#  updated_at           :datetime
#  questions_skipped    :integer          default(0)
#  questions_asked      :integer          default(0)
#  invitations          :integer          default(0)
#  invitations_accepted :integer          default(0)
#

