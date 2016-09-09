# Sends a notification email upon completion of SurveyResponse export processing.
# The email provides the recipient with a link to download the export file.
class ExportMailer < ActionMailer::Base
  @queue = :voc_csv

  default :from => "notifier@#{default_url_options[:host] || smtp_settings[:domain]}"

  def self.perform(emails, export_id)
    export_download(emails, export_id).deliver
  end

  # Send an email containing a download link for the provided export file.
  # @param [Array<string>] emails an array of email recipients for the notification
  # @param [Integer] export_id the identifier for the export file to be downloadable
  def export_download(emails, export_id, format)
    @export_file = Export.find export_id
    @format = format.to_s.upcase
    @download_url = "#{request.protocol}#{ENV.fetch('APP_ADMIN_HOST_PORT')}#{exports_download_path(:id => @export_file.access_token)}"

    mail to: emails, subject: "VOC Tool - Export Download - #{@export_file.survey_version.survey_name}"
  end
end
