# Manages the lifecycle of Choice Question HTML snippet entities.
class ChoiceQuestionsController < ApplicationController
  before_filter :get_survey_version

  # New.
  def new
    @choice_question = @survey_version.choice_questions.build
    
    build_default_choice_context(@choice_question)

    respond_to do |format|
      format.html #
      format.js
    end
  end

  # Create.
  def create
    @choice_question = ChoiceQuestion.new(params[:choice_question])
    @choice_question.survey_element.survey_version_id = @survey_version.id

    build_default_choice_context(@choice_question)

    respond_to do |format|
      if @choice_question.save
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
      else
        format.html {render :action => 'new'}
      end
      format.js { render :partial => "shared/element_create", :object => @choice_question, :as => :element }
    end
  end

  # Edit.
  def edit
    @choice_question = @survey_version.choice_questions.find(params[:id])

    respond_to do |format|
      format.html #
      format.js
    end
  end

  # Update.
  def update
    @choice_question = ChoiceQuestion.find(params[:id])
    respond_to do |format|
      if @choice_question.update_attributes(params[:choice_question])
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
      else
        format.html {render :action => 'edit'}
      end
      format.js { render :partial => "shared/element_create", :object => @choice_question, :as => :element }
    end
  end

  # Destroy. Also removes default Rule and Display Fields.
  def destroy
    @choice_question = ChoiceQuestion.find(params[:id])

    destroy_default_rule_and_display_field(@choice_question.question_content)

    @choice_question.destroy

    respond_to do |format|
      format.html { redirect_to text_questions_url, :notice => "Successfully deleted text question."}
      format.js { render :partial => "shared/element_destroy" }
    end
  end

  private
  
  # Load Survey and SurveyVersion information from the DB.
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = SurveyVersion.find(params[:survey_version_id])
  end

  # Clean up when destroying a ChoiceQuestion.
  def destroy_default_rule_and_display_field(qc)
    rule = @survey_version.rules.find_by_name(qc.statement)
    rule.destroy if rule.present?

    df = @survey_version.display_fields.find_by_name(qc.statement)
    df.destroy if df.present?
  end

  # Build the QuestionContent to allow the new/edit form to worl properly.
  def build_default_choice_context(choice_question)
    choice_question.build_question_content unless choice_question.question_content

    4.times {choice_question.choice_answers.build} if choice_question.choice_answers.empty?
  end

end
