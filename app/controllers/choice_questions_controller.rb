class ChoiceQuestionsController < ApplicationController
  before_filter :get_survey_version
  
  def new
    @choice_question = @survey_version.choice_questions.build
    
    respond_to do |format|
      format.html #
      format.js
    end
  end
  
  def create
    @choice_question = ChoiceQuestion.new(params[:choice_question])
    @choice_question.survey_element.survey_version_id = @survey_version.id
    
    respond_to do |format|
      if @choice_question.save
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
        format.js
      else
        format.html {render :action => 'new'}
        format.js
      end
    end  
  end

  def edit
    @choice_question = @survey_version.choice_questions.find(params[:id])
    
    respond_to do |format|
      format.html #
      format.js
    end
  end

  def update
    @choice_question = ChoiceQuestion.find(params[:id])
    respond_to do |format|
      if @choice_question.update_attributes(params[:choice_question])
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
        format.js   { render :create }
      else
        format.html {render :action => 'edit'}
        format.js   { render :create }
      end
    end
  end
  
  
  
  
  def destroy
    @choice_question = ChoiceQuestion.find(params[:id])
    @choice_question.destroy
    
    respond_to do |format|
      format.html { redirect_to text_questions_url, :notice => "Successfully deleted text question."}
      format.js
    end
  end
  
  private
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = SurveyVersion.find(params[:survey_version_id])
  end
  
end
