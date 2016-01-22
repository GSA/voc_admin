class SavedSearchesController < ApplicationController
  before_filter :set_survey_and_survey_version

  def index
    @saved_searches = @survey_version.saved_searches
  end

  def create
    @saved_search = @survey_version.saved_searches.build saved_search_params

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

    respond_to do |format|
      format.js { render text: "", status: 200 }
    end
  end

  private
  def set_survey_and_survey_version
    @survey = Survey.find params[:survey_id]
    @survey_version = @survey.survey_versions.find params[:survey_version_id]
  end

  def saved_search_params
    params.require(:saved_search).permit(:name, :search_params)
  end
end
