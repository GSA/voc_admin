class UserSessionsMailer < ActionMailer::Base
  default :from => "notifier@comment-adm.hhs.gov"

  def reset_password(user, password)
    @password = password
    mail(:to => user.email, :subject => "HHS VOC Tool Password Reset")
  end
end
