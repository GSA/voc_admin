# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the lifecycle of Choice Question HTML snippet entities.
class ChoiceQuestionsController < ApplicationController
  before_filter :get_survey_version

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/choice_questions/new(.:format)
  def new
    @choice_question = @survey_version.choice_questions.build
    @page = Page.find_by_id(params[:page_id])
    build_default_choice_context(@choice_question)

    respond_to do |format|
      format.html #
      format.js
    end
  end

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/choice_questions(.:format)
  def create
    @choice_question = ChoiceQuestion.new(params[:choice_question])
    @choice_question.survey_element.survey_version_id = @survey_version.id

    build_default_choice_context(@choice_question)

    respond_to do |format|
      if @choice_question.save
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added choice question."}
      else
        format.html {render :action => 'new'}
      end
      format.js { render :partial => "shared/element_create", :object => @choice_question, :as => :element }
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/choice_questions/:id/edit(.:format)
  def edit
    @choice_question = @survey_version.choice_questions.find(params[:id])

    respond_to do |format|
      format.html #
      format.js
    end
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/choice_questions/:id(.:format)
  def update
    @choice_question = ChoiceQuestion.find(params[:id])
    respond_to do |format|
      if @choice_question.update_attributes(params[:choice_question])
        @survey_version.mark_reports_dirty! if @survey_version.published?
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully updated choice question."}
      else
        format.html {render :action => 'edit'}
      end
      format.js { render :partial => "shared/element_create", :object => @choice_question, :as => :element }
    end
  end

  # DELETE /surveys/:survey_id/survey_versions/:survey_version_id/choice_questions/:id(.:format)
  # Also removes default Rule and Display Fields.
  def destroy
    @choice_question = ChoiceQuestion.find(params[:id])
    question_content_id = @choice_question.question_content.id
    destroy_default_rule_and_display_field(@choice_question)
    @choice_question.destroy
    respond_to do |format|
      format.html { redirect_to survey_path(@survey_version.survey), :notice => "Successfully deleted choice question."}
      format.js { render :partial => "shared/element_destroy" }
    end
    # Remove any rules which have actions that point to the choice question_content that just got deleted.
    Action.where("value LIKE ?", question_content_id).each do |a|
      if a.rule.present?
        a.rule.destroy
      end
    end
  end

  private

  # Clean up when destroying a ChoiceQuestion.
  def destroy_default_rule_and_display_field(choice_question)
    rule = @survey_version.rules.find_by_name(choice_question.question_content.statement)
    rule.destroy if rule.present?

    df = @survey_version.display_fields.find_by_name(choice_question.question_content.statement)
    df.destroy if df.present?
  end

  # Build the QuestionContent to allow the new/edit form to work properly.
  def build_default_choice_context(choice_question)
    choice_question.build_question_content unless choice_question.question_content

    4.times {choice_question.choice_answers.build} if choice_question.choice_answers.empty?
  end
end
