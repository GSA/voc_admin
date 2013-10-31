# Responsible for emailing reports.
class ReportsMailer < ActionMailer::Base
  include ResqueAsyncMailRunner
  @queue = :voc_report_email

  default :from => "notifier@#{default_url_options[:host] || smtp_settings[:domain]}"

  def report_csv(report_id, emails, from_user)
    @report = Report.find(report_id)
    @from_user = from_user
    attachments["report_#{report.id}.csv"] = {:mime_type => 'text/csv', :content => report.to_csv}
    mail :to => emails, 
         :subject => "Report: #{report.name}"
  end
end
