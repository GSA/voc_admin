# Responsible for emailing password reset instructions.
class UserSessionsMailer < ActionMailer::Base
  default :from => "notifier@comment-adm.hhs.gov"

  # Sends a password reset email to the specified user.
  #
  # @param [User] user the email recipient
  # @param [String] password the new password
  def reset_password(user, password)
    @password = password
    mail(:to => user.email, :subject => "HHS VOC Tool Password Reset")
  end
end
