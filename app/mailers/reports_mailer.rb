# Responsible for emailing reports.
class ReportsMailer < ActionMailer::Base
  include TokenAndSalt
  include ResqueAsyncMailRunner
  @queue = :voc_report_email

  default :from => "notifier@#{default_url_options[:host] || smtp_settings[:domain]}"

  def report_csv(report_id, emails, from_user, report_frequency)
    shared_settings(report_id, from_user, report_frequency)
    attachments["report_#{@report.id}.csv"] = {:mime_type => 'text/csv', :content => @report.to_csv}
    attach_question_reporter_csvs(@report.choice_question_reporters)
    attach_question_reporter_csvs(@report.text_question_reporters)
    @report_type = 'CSV'
    mail :to => emails,
         :subject => "Report CSV: #{@report.name}",
         :template_name => "report"
  end

  def report_pdf(report_id, emails, from_user, report_frequency)
    shared_settings(report_id, from_user, report_frequency)
    token, salt = token_and_salt
    url = survey_survey_version_pdf_report_url(@report.survey_version.survey_id, @report.survey_version_id, @report, :format => :pdf, :host => APP_CONFIG['admin_host'])
    file = open("#{url}&token=#{token}&salt=#{salt}", :allow_redirections => :safe, "Accept:" => "application/pdf").read
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

  def attach_question_reporter_csvs(reporters)
    reporters.each do |reporter|
      csv = reporter.to_csv(@report.start_date, @report.end_date)
      filename = friendly_filename("#{reporter.question_text}_#{reporter.id}")
      attachments["#{filename}.csv"] = {:mime_type => 'text/csv', :content => reporter.to_csv}
    end
  end

  def friendly_filename(filename)
    filename.gsub(/[^\w\s_-]+/, '') # Replaces characters that aren't letters or digits
            .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2') # Removes extra whitespace
            .gsub(/\s+/, '_') # Replaces remaining whitespace with underscores
  end
end
