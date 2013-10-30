# Responsible for emailing reports.
class ReportsMailer < ActionMailer::Base
  def report_csv(report, emails, from_user)
    @report = report
    attachments["report_#{report.id}.csv"] = {:mime_type => 'text/csv', :content => report.to_csv}
    mail :to => emails, 
         :subject => "Report: #{report.name}"
  end
end
