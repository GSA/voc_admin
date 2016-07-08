# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the lifecycle of TextQuestion entities.
class TextQuestionsController < ApplicationController
  before_filter :get_survey_version

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/text_questions(.:format)
  def index
    @text_questions = TextQuestion.all
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/text_questions/:id(.:format)
  def show
    @text_question = TextQuestion.find(params[:id])
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/text_questions/new(.:format)
  def new
    @text_question = @survey_version.text_questions.build
    @page = Page.find_by_id(params[:page_id])
    respond_to do |format|
      format.html #
      format.js
    end
  end

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/text_questions(.:format)
  def create
    @text_question = TextQuestion.new(params[:text_question])
    @text_question.survey_element.survey_version_id = @survey_version.id

    respond_to do |format|
      if @text_question.save
        format.html {
          redirect_to survey_path(@survey_version.survey),
            :notice => "Successfully added text question."
        }
      else
        format.html {render :action => 'new'}
      end
      format.js {
        render :partial => "shared/element_create", :object => @text_question, :as => :element
      }
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/text_questions/:id/edit(.:format)
  def edit
    @text_question = @survey_version.text_questions.find(params[:id])

    respond_to do |format|
      format.html #
      format.js
    end
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/text_questions/:id(.:format)
  def update
    @text_question = TextQuestion.find(params[:id])

    respond_to do |format|
      if @text_question.update_attributes(params[:text_question])
        @survey_version.mark_reports_dirty! if @survey_version.published?
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully updated text question."}
      else
        format.html {render :action => 'edit'}
      end
      format.js { render :partial => "shared/element_create", :object => @text_question, :as => :element }
    end
  end

  # DELETE /surveys/:survey_id/survey_versions/:survey_version_id/text_questions/:id(.:format)
  def destroy
    @text_question = TextQuestion.find(params[:id])
    question_content_id = @text_question.question_content.id
    destroy_default_rule_and_display_field(@text_question.question_content)
    @text_question.destroy
    respond_to do |format|
      format.html { redirect_to survey_path(@survey_version.survey), :notice => "Successfully deleted text question."}
      format.js { render :partial => "shared/element_destroy" }
    end
    # Remove any rules which have actions that point to the text question_content that just got deleted.
    Action.where("value LIKE ?", question_content_id).each do |a|
      if a.rule.present?
        a.rule.destroy
      end
    end
  end

  private

  # Clean up any rules which exist for the given question.
  #
  # @param [ChoiceQuestion] qc the ChoiceQuestion to clean up after.
  def destroy_default_rule_and_display_field(qc)
    rule = @survey_version.rules.find_by_name(qc.statement)
    rule.destroy if rule.present?

    df = @survey_version.display_fields.find_by_name(qc.statement)
    df.destroy if df.present?
  end
end
