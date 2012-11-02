class RulesMailer < ActionMailer::Base
  default :from => "notifier@comment-adm.hhs.gov"

  def email_action_notification(email_string, subject, body, survey_response_id)
    @survey_response = SurveyResponse.find(survey_response_id)
    @msg = body
    puts "Body: #{@msg}"

    puts mail(:to => email_string, :subject => subject)
  end
end
