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
    choice_questions.each {|key, value| value.merge!({:choice_answers_attributes => choice_answer_attributes, :answer_type => "radio"})}

    @matrix_question = @survey_version.matrix_questions.build(params[:matrix_question].merge({:survey_version_id => @survey_version.id}))
    @matrix_question.survey_element.survey_version_id = @survey_version.id
    
    # This sets a virtual attribute on each choice question's question content in order to create the correct name for display fields in the
    # after_create observer to get around the issue of the choice questions being saved before the matrix question's question content is saved
    # in the transaction.  This was causing matrix_question.statement to return an error
    @matrix_question.choice_questions.each do |cq|
      cq.question_content.matrix_statement = @matrix_question.question_content.statement
    end
  
    respond_to do |format|
      if @matrix_question.save
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
        format.js   {render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version, :survey => @survey}}
      else
        format.html {render :partial => 'new_matrix_question', :locals => {:survey => @survey, :survey_version => @survey_version} }
        format.js   {render :partial => "shared/question_errors", :locals => {:object => @matrix_question}, :status => 500}
      end
    end
  end

  def edit
    @matrix_question = @survey_version.matrix_questions.includes(:choice_questions => [:question_content, :choice_answers]).find(params[:id])
    
    respond_to do |format|
      format.html #
      format.js {render :action => :edit}
    end
  end

  def update
    choice_questions = params[:matrix_question][:choice_questions_attributes]
    
    choice_answer_attributes = params[:choice_answer_attributes]
    choice_questions.each {|key, value| value.merge!({:choice_answers_attributes => choice_answer_attributes, :answer_type => "radio"})}
    
    @matrix_question = MatrixQuestion.find(params[:id])
    
    respond_to do |format|
      if @matrix_question.update_attributes(params[:matrix_question])
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
        format.js   {render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version, :survey => @survey}}
      else
        format.html {render :partial => 'new_matrix_question', :locals => {:survey => @survey, :survey_version => @survey_version} }
        format.js   {render :partial => "shared/question_errors", :locals => {:object => @matrix_question}, :status => 500}
      end
    end
  end

  def destroy
    @matrix_question = @survey_version.matrix_questions.find(params[:id])
    @matrix_question.destroy
    
    respond_to do |format|
      format.html { redirect_to [@survey, @survey_version] , :notice => "Successfully destroyed Matrix question."}
      format.js   { render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version } }
    end
  end
  
  private
  def get_survey_and_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end
end
