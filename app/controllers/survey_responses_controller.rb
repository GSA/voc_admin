require 'csv'

class SurveyResponsesController < ApplicationController
  def index

    @survey_version_id = params[:survey_version_id].nil? ? nil : SurveyVersion.find(params[:survey_version_id])
    if @survey_version_id
      @order_column_id = @survey_version_id.display_fields.map(&:id).include?(params[:order_column].to_i) ? params[:order_column] : nil
      
    end
    @order_dir = %w(asc desc).include?(params[:order_dir].try(:downcase)) ? params[:order_dir] : 'asc'

    @survey_responses = SurveyResponse.search(params[:search])
    if @order_column_id
      @survey_responses = @survey_responses.order_by_display_field(@order_column_id, @order_dir) 
    else
      @survey_responses = @survey_responses.order("survey_responses.created_at #{@order_dir}")
    end
    @survey_responses = @survey_responses.page params[:page]
    
    
    respond_to do |format|
      format.html #
      format.js { render :partial => "survey_response_list", :locals => {:objects => @survey_responses, :version_id => @survey_version_id} }
      format.csv do
        @survey_version = SurveyVersion.find(@survey_version_id)
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
