# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
require 'csv'

# Allows for the download of CSV exports of SurveyResponse data.
class ExportsController < ApplicationController
  DOWNLOAD_AVAILABLE_FOR_IN_SECONDS = 86400 # 1 day

  # /exports/:id/download(.:format)
  # Endpoint to start the download process.
  def download
    @export_file = Export.active.find_by_access_token params[:id]

    if @export_file
      redirect_to @export_file.document.expiring_url(DOWNLOAD_AVAILABLE_FOR_IN_SECONDS)
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
