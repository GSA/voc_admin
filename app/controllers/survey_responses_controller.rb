require 'csv'

class SurveyResponsesController < ApplicationController
  def index

    @survey_version = params[:survey_version_id].nil? ? nil : SurveyVersion.find(params[:survey_version_id])


    if @survey_version.present?
      @survey_responses = @survey_version.survey_responses.processed

      # Get the order column and direction
      @order_column_id = @survey_version.display_fields.find_by_name(params[:order_column]).try(:id)
      @order_dir = %w(asc desc).include?(params[:order_dir].try(:downcase)) ? params[:order_dir] : 'asc'
            
      # if we have an order column, then order by that column
      if @order_column_id
        @survey_responses = @survey_responses.order_by_display_field(@order_column_id, @order_dir)
      else
        column = %w('survey_responses.created_at', 'page_url').include?(params[:order_column]) ? params[:order_column] : 'survey_responses.created_at'
        @survey_responses = @survey_responses.order("#{column} #{@order_dir}")
      end
      
      # If search parameters are sent in then use them to build the proper where clause
      if params[:search]
        @search = SurveyResponseSearch.new(@survey_version.id, params[:search])

        @survey_responses = @search.search(@survey_responses)
      end

      # Paginate the results
      @survey_responses = @survey_responses.includes(:display_field_values).page(params[:page]).per(10)

    else
      @survey_responses = []
    end    

    binding.pry if params[:debug] == true

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

  def edit
    @survey_response = SurveyResponse.find(params[:id])
  end

  def update
    @survey_response = SurveyResponse.find(params[:id])
    if @survey_response.update_attributes(params[:survey_response])
      redirect_to survey_responses_path(:survey_id => @survey_response.survey_version.survey_id, :survey_version_id => @survey_response.survey_version_id), :notice => "Successfully updated the record."
    else
      render :action => 'edit'
    end
  end

  ## You shouldn't be able to create survey responses from the admin app
  def create
    @client_id = SecureRandom.hex(64)
    @survey_version_id = params[:survey_version_id]
    
    @survey_response = SurveyResponse.new ({:client_id => @client_id, :survey_version_id => @survey_version_id}.merge(params[:response]))
    
    @survey_response.raw_responses.each {|raw_response| raw_response.client_id = @client_id}
    
    @survey_response.save!
    
    redirect_to survey_responses_path
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
    
    # Generate the csv file in the background in case there are a large number of responses
    @survey_version.delay.generate_responses_csv(params[:search], current_user.id)

    respond_to do |format|
      format.html {redirect_to survey_responses_path(:survey_id => @survey_version.survey_id, :survey_version_id => @survey_version.id)}
      format.js
    end
    
  end
end