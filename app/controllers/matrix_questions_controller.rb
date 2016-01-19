# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the MatrixQuestion lifecycle.
class MatrixQuestionsController < ApplicationController
  before_filter :get_survey_version

  # GET /surveys/:survey_id/survey_versions/:survey_version_id/matrix_questions/new(.:format)
  def new
    @matrix_question = @survey_version.matrix_questions.build
    @page = Page.find_by_id(params[:page_id])

    respond_to do |format|
      format.html #
      format.js
    end
  end

  # POST /surveys/:survey_id/survey_versions/:survey_version_id/matrix_questions(.:format)
  def create
    choice_questions = params[:matrix_question][:choice_questions_attributes]

    choice_answer_attributes = params[:choice_answer_attributes] || {}
    choice_questions.each { |key, value|
      value.merge!({
        :choice_answers_attributes => choice_answer_attributes,
        :answer_type => "radio"
      })
    }

    @matrix_question = @survey_version.matrix_questions.build(
      params[:matrix_question].merge({:survey_version_id => @survey_version.id})
    )
    @matrix_question.survey_element.survey_version_id = @survey_version.id

    # This sets a virtual attribute on each choice question's question content
    # in order to create the correct name for display fields in the
    # after_create observer to get around the issue of the choice questions
    # being saved before the matrix question's question content is saved
    # in the transaction.  This was causing matrix_question.statement to return
    # an error in the after_create observer
    @matrix_question.choice_questions.each do |cq|
      cq.question_content.matrix_statement = @matrix_question.question_content
        .try(:statement)
    end

    respond_to do |format|
      if @matrix_question.save
        format.html {
          redirect_to survey_path(@survey_version.survey),
            :notice => "Successfully added Matrix question."
        }
      else
        format.html {render :new }
      end
      format.js {
        render :partial => "shared/element_create", :object => @matrix_question,
        :as => :element
      }
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/matrix_questions/:id/edit(.:format)
  def edit
    @matrix_question = @survey_version.matrix_questions
      .includes(:choice_questions => [:question_content, :choice_answers])
      .find(params[:id])

    respond_to do |format|
      format.html #
      format.js
    end
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/matrix_questions/:id(.:format)
  def update
    @matrix_question = MatrixQuestion.find(params[:id])
    choice_questions = params.fetch(:matrix_question, {})
      .fetch(:choice_questions_attributes, {})

    choice_answer_attributes = params[:choice_answer_attributes] || {}
    choice_questions.each {|key, value| value.deep_merge!({:choice_answers_attributes => choice_answer_attributes,
     :answer_type => "radio", :question_content_attributes => {:matrix_statement => @matrix_question.question_content.try(:statement)}})}

    respond_to do |format|
      if @matrix_question.update_attributes(params[:matrix_question])
        @matrix_question.remove_deleted_sub_questions(choice_questions)
        @survey_version.mark_reports_dirty! if @survey_version.published?
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added Matrix question."}
      else
        format.html {render :partial => 'new_matrix_question', :locals => {:survey => @survey_version.survey, :survey_version => @survey_version} }
      end
      format.js { render :partial => "shared/element_create", :object => @matrix_question, :as => :element }
    end
  end

  # DELETE /surveys/:survey_id/survey_versions/:survey_version_id/matrix_questions/:id(.:format)
  def destroy
    @matrix_question = @survey_version.matrix_questions.find(params[:id])
    qc_ids = Array.new
    @matrix_question.choice_questions.each do |c|
      qc_ids << c.question_content.id
    end
    destroy_default_rule_and_display_field(@matrix_question)
    @matrix_question.destroy
    respond_to do |format|
      format.html { redirect_to [@survey, @survey_version] , :notice => "Successfully deleted Matrix question."}
      format.js { render :partial => "shared/element_destroy" }
    end
    #Remove any rules which have actions pointing to the question_content of the matrix_question which just got deleted.
    qc_ids.each do |q|
      if !QuestionContent.find_by_id(q).present?
        Action.where("value LIKE ?", q).each do |a|
          if a.rule.present?
            a.rule.destroy
          end
        end
      end
    end
  end

  private
  # Removes the default Rule and DisplayField mappings for a given
  # MatrixQuestion across ChoiceQuestions.
  #
  # @param [MatrixQuestion] question the MatrixQuestion to clean up after
  def destroy_default_rule_and_display_field(question)
    question.choice_questions.each do |choice_question|
      name ="#{question.question_content.statement}: #{choice_question.question_content.statement}"

      rule = @survey_version.rules.find_by_name(name)
      rule.destroy if rule.present?

      df = @survey_version.display_fields.find_by_name(name)
      df.destroy if df.present?
    end
  end
end
