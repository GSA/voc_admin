# Responsible for emailing reports.
class ReportsMailer < ActionMailer::Base
  include TokenAndSalt
  include ResqueAsyncMailRunner
  @queue = :voc_report_email

  default :from => "notifier@#{default_url_options[:host] || smtp_settings[:domain]}"

  def report_csv(report_id, emails, from_user)
    @report = Report.find(report_id)
    @from_user = from_user
    attachments["report_#{@report.id}.csv"] = {:mime_type => 'text/csv', :content => @report.to_csv}
    mail :to => emails, 
         :subject => "Report CSV: #{@report.name}"
  end

  def report_pdf(report_id, report_url, emails, from_user)
    @report = Report.find(report_id)
    @from_user = from_user
    token, salt = token_and_salt
    file = open("#{report_url}?token=#{token}&salt=#{salt}").read
    attachments["report_#{@report.id}.pdf"] = {:mime_type => 'application/pdf', :content => file}
    mail :to => emails, 
         :subject => "Report PDF: #{@report.name}"
  end
end
