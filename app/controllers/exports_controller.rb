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
      send_file @export_file.document.path, :type => @export_file.document_content_type, :disposition => 'attachment', :filename => @export_file.document_file_name
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
