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
    
    
    respond_to do |format|
      if @text_question.save
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
        format.js   {render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version}}
      else
        format.html {render :action => 'new'}
        format.js   {render :partial => "shared/question_errors", :locals => {:object => @text_question}, :status => 500}
      end
    end
  end

  def edit
    @text_question = @survey_version.text_questions.find(params[:id])
    
    respond_to do |format|
      format.html #
      format.js {render :action => :edit}
    end
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
    
    respond_to do |format|
      format.html { redirect_to text_questions_url, :notice => "Successfully destroyed text question."}
      format.js   { render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version } }
    end
  end
  
  private
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end

end
