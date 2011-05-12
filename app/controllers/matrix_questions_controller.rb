class MatrixQuestionsController < ApplicationController
  before_filter :get_survey_and_survey_version
  
  def index
    @matrix_questions = @survey_version.matrix_questions
  end

  def show
    @matrix_question = @survey_version.matrix_questions.find(params[:id])
  end

  def new
    @matrix_question = @survey_version.matrix_questions.build
  end

  def create
    choice_questions = params[:matrix_question][:choice_questions_attributes]
    
    choice_answer_attributes = params[:choice_answer_attributes]
    choice_questions.each {|key, value| value.merge!({:choice_answer_attributes => choice_answer_attributes})}
    
    @matrix_question = @survey_version.matrix_questions.build(params[:matrix_question])
    @matrix_question.survey_element.survey_version_id = @survey_version.id
    
    respond_to do |format|
      if @matrix_question.save
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
        format.js   {render :partial => "surveys/question_list", :locals => {:survey_version => @survey_version}}
      else
        format.html {render :partial => 'new_matrix_question', :locals => {:survey => @survey} }
        format.js   {render :partial => "shared/question_errors", :locals => {:object => @matrix_question}, :status => 500}
      end
    end
  end

  def edit
    @matrix_question = @survey_version.matrix_questions.find(params[:id])
  end

  def update
    @matrix_question = @survey_version.matrix_questions.find(params[:id])
    if @matrix_question.update_attributes(params[:matrix_question])
      redirect_to [@survey, @survey_version], :notice  => "Successfully updated matrix question."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @matrix_question = @survey_version.matrix_questions.find(params[:id])
    @matrix_question.destroy
    redirect_to [@survey, @survey_version], :notice => "Successfully destroyed matrix question."
  end
  
  private
  def get_survey_and_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end
end
