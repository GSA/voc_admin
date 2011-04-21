class SurveyVersionsController < ApplicationController
  before_filter :get_survey
  
  
  def index
    @survey_versions = @survey.survey_versions.order("major desc, minor desc").all
    
    respond_to do |format|
      format.html #
      format.js {render :json => [{:value => 0, :display => "Choose a version"}].concat(@survey_versions.collect {|s| {:value => s.id, :display => s.version_number}}) }
    end
  end
  
  private
  def get_survey
    @survey = Survey.find(params[:survey_id])
  end
end
