# Mailer corresponding to the EmailAction class; sends an email
# when criteria are met for an EmailAction to be triggered.
class RulesMailer < ActionMailer::Base
  @queue = :voc_rules

  default :from => "notifier@#{default_url_options[:host] || smtp_settings[:domain]}"

  def self.perform(email_string, subject, body, survey_response_id)
    email_action_notification(email_string, subject, body, survey_response_id).deliver
  end

  # Send an email notification due to a Rule with an EmailAction firing.
  #
  # @param [String] email_string the email address of the recipient
  # @param [String] subject the subject of the email
  # @param [String] body the body of the email
  # @param [Integer] survey_response_id the id of the matching SurveyResponse record
  def email_action_notification(email_string, subject, body, survey_response_id)
    @survey_response = SurveyResponse.find(survey_response_id)
    @msg = body

    mail(:to => email_string, :subject => subject)
  end
end
