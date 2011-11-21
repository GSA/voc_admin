class UserSessionsMailer < ActionMailer::Base
  default :from => "from@example.com"
  
  def reset_password(user, password)
    @password = password
    mail(:to => user.email, :subject => "HHS VOC Tool Password Reset")
  end
end
