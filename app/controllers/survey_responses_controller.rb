require 'csv'

# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the SurveyResponse lifecycle.
class SurveyResponsesController < ApplicationController

  # Used to limit the passthrough effects of params when updating or deleting SurveyResponses and the grid needs updating.
  POST_PARAMS = [:survey_id, :survey_version_id, :page, :id, :survey_response, :response, :search, :simple_search, :order_column, :order_dir, :custom_view_id, :qc_id, :search_rr]

  # GET    /survey_responses(.:format)
  def index
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
    if @survey_response.update_attributes(params[:survey_response])
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

  # GET    /survey_responses/export_all(.:format)
  def export_all
    @survey_version = SurveyVersion.find(params[:survey_version_id])

    # Generate the csv file in the background in case there are a large number of responses
    @survey_version.async(:generate_responses_csv, params, current_user.id)

    respond_to do |format|
      format.html {redirect_to survey_responses_path(:survey_id => @survey_version.survey_id, :survey_version_id => @survey_version.id)}
      format.js
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
      @survey_responses = paginate_responses(@survey_responses.includes(:display_field_values), params[:page].to_i)
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
    pages -= 1 if (pages > 2 && responses.count <= SurveyResponse.default_per_page * (pages - 1))
    total_count = @es_results["hits"]["total"]
    Kaminari.paginate_array(responses, total_count: total_count).page(pages).per(SurveyResponse.default_per_page)
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

  # Calculate the proper ordering of the SurveyResponse grid. Order of precedence:
  #   Explicit query parameter.
  #   Created By date or Page Url fields.
  #   Custom View.
  #   Default to Created By date.
  def responses_order
    # Get the order column and direction
    @order_column_id = @survey_version.display_fields.find_by_name(params[:order_column]).try(:id)
    @order_dir = %w(asc desc).include?(params[:order_dir].try(:downcase)) ? params[:order_dir].downcase : 'asc'

    if @order_column_id
      elastic_sort("df_#{@order_column_id}", @order_dir)
    elsif params[:order_column] == "survey_responses.created_at"
      elastic_sort("created_at", @order_dir)
    elsif %w(page_url device).include?(params[:order_column])
      elastic_sort(params[:order_column], @order_dir)
    elsif @custom_view
      sort_arr = @custom_view.sorted_display_field_custom_views.map do |s|
        elastic_sort("df_#{s.display_field_id}", s.sort_direction)
      end
      sort_arr.join(",")
    else # fall back on date if we have no other recourse
      elastic_sort("created_at", @order_dir)
    end
  end

  # If search parameters are sent in, use them to build the proper WHERE clause.
  def search_responses
    sv_id = @survey_version.id
    if params[:search].present?
      @search = SurveyResponseSearch.new(params[:search])

      @survey_responses = @search.search(@survey_responses)
    elsif params[:simple_search].present?
      @es_results, @survey_responses = ElasticSearchResponse.search(sv_id, params[:simple_search], responses_order)
    elsif params[:search_rr].present?
      @survey_responses = @survey_responses.search_rr(params[:qc_id], params[:search_rr])
    else
      @es_results, @survey_responses = ElasticSearchResponse.search(sv_id, "", responses_order)
    end
  end

  def elastic_sort(column, sort_direction)
    "#{column}.raw:#{sort_direction}"
  end
end
