# Responsible for emailing password reset instructions.
class UserSessionsMailer < ActionMailer::Base
  default :from => "notifier@#{smtp_settings[:domain] || default_url_options[:host]}"

  # Sends a password reset email to the specified user.
  #
  # @param [User] user the email recipient
  # @param [String] password the new password
  def reset_password(user, password)
    @password = password
    mail(:to => user.email, :subject => "VOC Tool Password Reset")
  end
end
