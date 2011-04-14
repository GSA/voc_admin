class ChoiceQuestionsController < ApplicationController
  before_filter :get_survey_version
  
  def create
    @choice_question = ChoiceQuestion.new(params[:choice_question])
    @choice_question.survey_element.survey_version_id = @survey_version.id
    
    if @choice_question.save
      redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."
    else
      render :action => 'new'
    end    
  end
  
  private
  def get_survey_version
    @survey_version = SurveyVersion.find(params[:survey_version_id])
  end
  
end
