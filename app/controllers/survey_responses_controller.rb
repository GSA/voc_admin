require 'csv'

class SurveyResponsesController < ApplicationController
  def index

    @survey_version = params[:survey_version_id].nil? ? nil : SurveyVersion.find(params[:survey_version_id])
    
    if @survey_version.present?
      @order_column_id = @survey_version.display_fields.find_by_name(params[:order_column]).try(:id)
      @order_dir = %w(asc desc).include?(params[:order_dir].try(:downcase)) ? params[:order_dir] : 'asc'
      
      @survey_responses = @survey_version.survey_responses.processed.search(params[:search])
      
      if @order_column_id
        @survey_responses = @survey_responses.order_by_display_field(@order_column_id, @order_dir)
      else
        column = %w('created_at', 'page_url').include?(params[:order_column]) ? params[:order_column] : 'created_at'
        @survey_responses = @survey_responses.order("#{column} #{@order_dir}")
      end
      
      @survey_responses = @survey_responses.page(params[:page]).per(10)

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

  ## You shouldn't be able to create survey responses from the admin app
  def create
    # @client_id = SecureRandom.hex(64)
    # @survey_version_id = params[:survey_version_id]
    
    # @survey_response = SurveyResponse.new ({:client_id => @client_id, :survey_version_id => @survey_version_id}.merge(params[:response]))
    
    # @survey_response.raw_responses.each {|raw_response| raw_response.client_id = @client_id}
    
    # @survey_response.save!
    
    # redirect_to survey_responses_path
  end

  def destroy
    @survey_response = SurveyResponse.find(params[:id])

    @survey_response.archive

    respond_to do |format|
      format.html #
      format.js { render :partial => "survey_response_list", :locals => {:objects => @survey_response.survey_version.survey_responses.page(params[:page]), :version_id => @survey_response.survey_version_id} }
    end
  end

  def export_all
    @survey_version = SurveyVersion.find(params[:survey_version_id])

    ## It’s not possible to set the order. That is automatically set to ascending on the primary key (“id ASC”) to make the batch ordering work. 
    ## This also mean that this method only works with integer-based primary keys. 
    ## You can’t set the limit either, that’s used to control the batch sizes.
    # @order_column_id = @survey_version.display_fields.find_by_name(params[:order_column]).try(:id)
    # @order_dir = %w(asc desc).include?(params[:order_dir].try(:downcase)) ? params[:order_dir] : 'asc'
    
    @survey_responses = @survey_version.survey_responses.processed.search(params[:search])

    respond_to do |format|
      format.csv do
        @survey_version
        response.headers["Content-Type"]        = "text/csv; header=present"
        response.headers["Content-Disposition"] = "attachment; filename=responses.csv"
      end
    end
  end
end