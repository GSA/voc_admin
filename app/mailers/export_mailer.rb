class ExportMailer < ActionMailer::Base
  default :from => "notifier@comment-adm.hhs.gov"

  # export_download - Send an email containing a download link for the provided export file
  #   emails:         array of email recipients for the notification
  #   export_id:   export file to be downloadable through the email link
  def export_download(emails, export_id)
      @export_file = Export.find export_id

      mail to: emails, subject: "HHS VOC Tool - Export Download"
  end
end
