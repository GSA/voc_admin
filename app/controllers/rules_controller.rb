class RulesController < ApplicationController
  before_filter :get_survey_version
  
  def index
    @rules = @survey_version.rules
  end
  
  private
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end
end
