class TextQuestionsController < ApplicationController
  before_filter :get_survey_version
  
  def index
    @text_questions = TextQuestion.all
  end

  def show
    @text_question = TextQuestion.find(params[:id])
  end

  def new
    @text_question = TextQuestion.new
  end

  def create
    @text_question = TextQuestion.new(params[:text_question])
    @text_question.survey_element.survey_version_id = @survey_version.id
    
    if @text_question.save
      redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."
    else
      render :action => 'new'
    end
  end

  def edit
    @text_question = TextQuestion.find(params[:id])
  end

  def update
    @text_question = TextQuestion.find(params[:id])
    if @text_question.update_attributes(params[:text_question])
      redirect_to @text_question, :notice  => "Successfully updated text question."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @text_question = TextQuestion.find(params[:id])
    @text_question.destroy
    redirect_to text_questions_url, :notice => "Successfully destroyed text question."
  end
  
  private
  def get_survey_version
    @survey_version = SurveyVersion.find(params[:survey_version_id])
  end

end
