class SurveyElementsController < ApplicationController
  before_filter :get_survey_version
  
  def up
    @element = SurveyElement.find(params[:id])
    @element.move_element_up
    
    respond_to do |format|
      format.js {render :partial => "surveys/question_list", :locals => {:survey_version => @survey_version}}
    end
  end

  def down
    @element = SurveyElement.find(params[:id])
    @element.move_element_down
      
    respond_to do |format|
      format.js {render :partial => "surveys/question_list", :locals => {:survey_version => @survey_version}}
    end
  end

  private
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end

end