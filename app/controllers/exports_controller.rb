# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
require 'csv'

# Allows for the download of CSV exports of SurveyResponse data.
class ExportsController < ApplicationController

  # /exports/:id/download(.:format)
  # Endpoint to start the download process.
  def download
    @export_file = Export.active.find_by_access_token params[:id]

    if @export_file
      redirect_to @export_file.document.url
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
