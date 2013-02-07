# Sends a notification email upon completion of SurveyResponse export processing.
# The email provides the recipient with a link to download the export file.
class ExportMailer < ActionMailer::Base
  default :from => "notifier@#{smtp_settings[:domain] || default_url_options[:host]}"

  # Send an email containing a download link for the provided export file.
  # @param [Array<string>] emails an array of email recipients for the notification
  # @param [Integer] export_id the identifier for the export file to be downloadable
  def export_download(emails, export_id)
      @export_file = Export.find export_id

      mail to: emails, subject: "VOC Tool - Export Download"
  end
end
