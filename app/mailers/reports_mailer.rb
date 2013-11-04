# Responsible for emailing reports.
class ReportsMailer < ActionMailer::Base
  include TokenAndSalt
  include ResqueAsyncMailRunner
  @queue = :voc_report_email

  default :from => "notifier@#{default_url_options[:host] || smtp_settings[:domain]}"

  def report_csv(report_id, emails, from_user, report_frequency)
    shared_settings(report_id, from_user, report_frequency)
    attachments["report_#{@report.id}.csv"] = {:mime_type => 'text/csv', :content => @report.to_csv}
    @report_type = 'CSV'
    mail :to => emails, 
         :subject => "Report CSV: #{@report.name}",
         :template_name => "report"
  end

  def report_pdf(report_id, emails, from_user, report_frequency)
    shared_settings(report_id, from_user, report_frequency)
    token, salt = token_and_salt
    url = survey_survey_version_pdf_report_url(@report.survey_version.survey_id, @report.survey_version_id, @report, :format => :pdf)
    file = open("#{url}?token=#{token}&salt=#{salt}").read
    attachments["report_#{@report.id}.pdf"] = {:mime_type => 'application/pdf', :content => file}
    @report_type = 'PDF'
    mail :to => emails, 
         :subject => "Report PDF: #{@report.name}",
         :template_name => "report"
  end

  private
  def shared_settings(report_id, from_user, report_frequency)
    @report = Report.find(report_id)
    @from_user = from_user
    @report_frequency = report_frequency
  end
end
