class SavedSearchesController < ApplicationController
  before_filter :set_survey_and_survey_version

  def index
    @saved_searches = @survey_version.saved_searches
  end

  def create
    @saved_search = @survey_version.saved_searches.build params[:saved_search]

    if @saved_search.save
      respond_to do |format|
        format.js #
      end
    else
      respond_to do |format|
        format.js { render status: 400, json: {errors: @saved_search.errors.full_messages.to_json} }
      end
    end
  end

  def destroy
    @saved_search = @survey_version.saved_searches.find params[:id]
    @saved_search.destroy

    redirect_to survey_responses_path survey_version_id: @survey_version.id, survey_id: @survey.id
  end

  private
  def set_survey_and_survey_version
    @survey = Survey.find params[:survey_id]
    @survey_version = @survey.survey_versions.find params[:survey_version_id]
  end
end
