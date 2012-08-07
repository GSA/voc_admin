require 'csv'

class ExportsController < ApplicationController
  def download
    @export_file = Export.find_by_access_token params[:id]

    send_file @export_file.document.path, :type => @export_file.document_content_type, :disposition => 'attachment', :filename => @export_file.document_file_name
  end
end