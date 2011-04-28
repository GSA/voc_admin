class ChoiceQuestionsController < ApplicationController
  before_filter :get_survey_version
  
  def create
    @choice_question = ChoiceQuestion.new(params[:choice_question])
    @choice_question.survey_element.survey_version_id = @survey_version.id
    
    respond_to do |format|
      if @choice_question.save
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
        format.js   {render :partial => "surveys/question_list", :locals => {:survey_version => @survey_version}}
      else
        format.html {render :action => 'new'}
        format.js   {render :partial => "shared/question_errors", :locals => {:object => @choice_question}, :status => 500}
      end
    end  
  end
  
  def destroy
    @choice_question = ChoiceQuestion.find(params[:id])
    @choice_question.destroy
    
    respond_to do |format|
      format.html { redirect_to text_questions_url, :notice => "Successfully destroyed text question."}
      format.js   { render :partial => "surveys/question_list", :locals => {:survey_version => @survey_version } }
    end
  end
  
  private
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = SurveyVersion.find(params[:survey_version_id])
  end
  
end
