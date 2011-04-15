class SurveyVersionsController < ApplicationController
  before_filter :get_survey
  
  
  def index
    @survey_versions = @survey.survey_versions.all
  end
  
  private
  def get_survey
    @survey = Survey.find(params[:survey_id])
  end
end
