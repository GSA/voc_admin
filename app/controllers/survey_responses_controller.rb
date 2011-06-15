require 'csv'

class SurveyResponsesController < ApplicationController
  def index

    @survey_version = params[:survey_version_id].nil? ? nil : SurveyVersion.find(params[:survey_version_id])
    if @survey_version
      @order_column_id = @survey_version.display_fields.map(&:id).include?(params[:order_column].to_i) ? params[:order_column] : nil
      @order_dir = %w(asc desc).include?(params[:order_dir].try(:downcase)) ? params[:order_dir] : 'asc'
  
      @survey_responses = @survey_version.survey_responses.search(params[:search])
      if @order_column_id
        @survey_responses = @survey_responses.order_by_display_field(@order_column_id, @order_dir) 
      else
        @survey_responses = @survey_responses.order("survey_responses.created_at #{@order_dir}")
      end
      @survey_responses = @survey_responses.page params[:page]
    else
      @survey_responses = []
    end    
    
    respond_to do |format|
      format.html #
      format.js { render :partial => "survey_response_list", :locals => {:objects => @survey_responses, :version_id => @survey_version} }
      format.csv do
        @survey_version
        response.headers["Content-Type"]        = "text/csv; header=present"
        response.headers["Content-Disposition"] = "attachment; filename=responses.csv"
      end
    end
  end
  
  def create
    @client_id = SecureRandom.hex(64)
    @survey_version_id = params[:survey_version_id]
    
    @survey_response = SurveyResponse.new ({:client_id => @client_id, :survey_version_id => @survey_version_id}.merge(params[:response]))
    
    @survey_response.raw_responses.each {|r| r.client_id = @client_id}
    
    @survey_response.save!
    
    redirect_to survey_responses_path
  end

end
