# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
require 'csv'

# Allows for the download of CSV exports of SurveyResponse data.
class ExportsController < ApplicationController
  DOWNLOAD_AVAILABLE_FOR_IN_SECONDS = 86400 # 1 day

  skip_before_filter :require_user

  # /exports/:id/download(.:format)
  # Endpoint to start the download process.
  def download
    @export_file = Export.active.find_by_access_token params[:id]

    if @export_file
      path = @export_file.document.path
      mime_type = Mime::Type.lookup_by_extension(path.split('.').last).to_s

      data = open(@export_file.document.expiring_url(DOWNLOAD_AVAILABLE_FOR_IN_SECONDS))
      send_data(data.read,
                filename: File.basename(path),
                type: mime_type,
                disposition: 'attachment')
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
