require 'csv'

# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the SurveyResponse lifecycle.
class SurveyResponsesController < ApplicationController

  # Used to limit the passthrough effects of params when updating or deleting SurveyResponses and the grid needs updating.
  POST_PARAMS = [:survey_id, :survey_version_id, :page, :id, :survey_response_id, :survey_response, :response, :search, :simple_search, :order_column, :order_dir, :custom_view_id, :qc_id, :search_rr, :file_type]

  # GET    /survey_responses(.:format)
  def index
    params.reject! {|k,v| v.blank?}
    build_survey_version_and_responses

    respond_to do |format|
      format.html #
      format.js
      format.csv do
        @survey_version
        response.headers["Content-Type"]        = "text/csv; header=present"
        response.headers["Content-Disposition"] = "attachment; filename=responses.csv"
      end
    end
  end

  # GET    /survey_responses/:id/edit(.:format)
  def edit
    if params[:id] == 'next_page'
      params[:page] ||= 1
      params[:page] = params[:page].to_i + 1
    elsif params[:id] == 'previous_page'
      params[:page] = params[:page].to_i - 1
    end
    build_survey_version_and_responses
    if params[:id] == 'next_page'
      params[:id] = @survey_responses.first.id.to_s
    elsif params[:id] == 'previous_page'
      params[:id] = @survey_responses[-1].id.to_s # Using #last gives the last record of all responses for some reason
    end
    @survey_response = SurveyResponse.find(params[:id])
  end

  # PUT    /survey_responses/:id(.:format)
  def update
    @survey_response = SurveyResponse.find(params[:id])
    if @survey_response.update_attributes(survey_response_params)
      redirect_to survey_responses_path(params.slice(*SurveyResponsesController::POST_PARAMS).except(:survey_response)), :notice => "Successfully updated the record."
    else
      render :action => 'edit'
    end
  end

  # DELETE /survey_responses/:id(.:format)
  def destroy
    @survey_response = SurveyResponse.find(params[:id])
    @survey_response.archive

    build_survey_version_and_responses

    @paginate_params = { :controller => 'survey_responses', :action => 'index', :id => nil, :params => params.slice(*SurveyResponsesController::POST_PARAMS) }

    respond_to do |format|
      format.html #
      format.js { render :action => 'index' }
    end
  end

  # GET    /survey_responses/export_csv(.:format)
  def export_csv
    @survey_version = SurveyVersion.find(params[:survey_version_id])
    # Generate the csv file in the background in case there are a large number of responses
    @survey_version.async(:generate_responses_csv, params, current_user.id)
    respond_to do |format|
      format.html {redirect_to survey_responses_path(:survey_id => @survey_version.survey_id, :survey_version_id => @survey_version.id)}
      format.js { render 'export_all', layout: false }
    end
  end

  # GET    /survey_responses/export_xls(.:format)
  def export_xls
    @survey_version = SurveyVersion.find(params[:survey_version_id])
    # Generate the csv file in the background in case there are a large number of responses
    @survey_version.async(:generate_responses_xls, params, current_user.id)
    respond_to do |format|
      format.html {redirect_to survey_responses_path(:survey_id => @survey_version.survey_id, :survey_version_id => @survey_version.id)}
      format.js { render 'export_all', layout: false }
    end
  end

  private

  # Find survey version, evaluate custom view, set ordering, then filter on search.
  def build_survey_version_and_responses
    @survey_version = params[:survey_version_id].nil? ? nil : SurveyVersion.find(params[:survey_version_id])

    if @survey_version.present?
      set_custom_view
      search_responses
      # Paginate the results
      @survey_responses = paginate_responses(
        @survey_responses.includes(:display_field_values),
        params[:page].to_i
      )
    else
      @survey_responses = []
    end
  end

  # Largely responsible for ensuring that pagination shows the proper page if a survey
  # response is deleted by an admin user.  Will decrement page number of the current page
  # would no longer show any responses.
  #
  # @param [ActiveRecord::Relation] responses the ActiveRecord relation query
  # @param [Integer] pages the expected Page number
  # @return [ActiveRecord::Relation] the paginated Relation
  def paginate_responses(responses, pages)
    # decrement the requested page if the response count falls below the pagination threshold
    # pages -= 1 if (pages > 2 && responses.count <= SurveyResponse.default_per_page * (pages - 1))
    total_count = @es_results["hits"]["total"]
    Kaminari.paginate_array(responses, total_count: total_count)
      .page(pages)
      .per(SurveyResponse.default_per_page)
  end

  # Uses the query parameter CustomView, the default CustomView for
  # the survey version, or no CustomView whatsoever.
  def set_custom_view
    # Set the custom view from the params
    @custom_view = nil

    if params[:custom_view_id].blank?
      @custom_view = @survey_version.custom_views.find_by_default(true)
    else
      # Use find_by_id in order to return nil if a custom view with the specified id
      # cannot be found instead of raising an error.
      @custom_view = @survey_version.custom_views.find_by_id(params[:custom_view_id])
    end
  end

  # If search parameters are sent in, use them to build the proper WHERE clause.
  def search_responses
    if params[:search].present? && params[:search][:criteria].all? {|k,v| v[:value].blank?}
      params[:search] = nil
    end
    survey_response_query = SurveyResponsesQuery.new(
      @survey_version, @custom_view, params,
      {page: params[:page].present? ? params[:page].to_i - 1 : 0 }
    )
    @es_results, @survey_responses = survey_response_query.search
    @search = survey_response_query.search_criteria
  end

  def survey_response_params
    params.require(:survey_response).permit(
      display_field_values_attributes: [:id, :value]
    )
  end

end
