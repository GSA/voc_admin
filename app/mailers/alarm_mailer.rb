class AlarmMailer < ActionMailer::Base

  def alarm(email, name)
    @name = name
    mail to: email, subject: "VOC Tool - No respones received for #{name}"
  end
end