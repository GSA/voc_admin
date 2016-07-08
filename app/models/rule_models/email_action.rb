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
    resque_args = self.emails, self.subject, self.body, survey_response.id

    begin
      Resque.enqueue(RulesMailer, *resque_args)
    rescue
      ResquedJob.create(class_name: "RulesMailer", job_arguments: resque_args)
    end
  end
end

# == Schema Information
#
# Table name: email_actions
#
#  id          :integer          not null, primary key
#  emails      :string(255)
#  subject     :string(255)
#  body        :text
#  rule_id     :integer
#  clone_of_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

