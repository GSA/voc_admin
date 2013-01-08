# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# An EmailAction is the component of the Rules system which invokes the mailer to send a specific message.
class EmailAction < ActiveRecord::Base
  belongs_to :rule
  has_one :clone_of, :class_name => "EmailAction"

  validates :emails, :presence => true
  validates :subject, :presence => true
  validates :body, :presence => true

  # Invokes the Email Action for a given SurveyResponse.  Invokes the mailer to send a specific message.
  #
  # @param [SurveyResponse] survey_response the SurveyResponse to notify recipients about
  def perform(survey_response)
    RulesMailer.delay.email_action_notification(self.emails, self.subject, self.body, survey_response.id)
  end
end

# == Schema Information
#
# Table name: email_actions
#
#  id          :integer(4)      not null, primary key
#  emails      :string(255)
#  subject     :string(255)
#  body        :text
#  rule_id     :integer(4)
#  clone_of_id :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

