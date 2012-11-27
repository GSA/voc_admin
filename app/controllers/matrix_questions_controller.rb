class MatrixQuestionsController < ApplicationController
  before_filter :get_survey_and_survey_version

  def new
    @matrix_question = @survey_version.matrix_questions.build

    respond_to do |format|
      format.html #
      format.js
    end
  end

  def create
    choice_questions = params[:matrix_question][:choice_questions_attributes]

    choice_answer_attributes = params[:choice_answer_attributes] || {}
    choice_questions.each {|key, value| value.merge!({:choice_answers_attributes => choice_answer_attributes, :answer_type => "radio"})}

    @matrix_question = @survey_version.matrix_questions.build(params[:matrix_question].merge({:survey_version_id => @survey_version.id}))
    @matrix_question.survey_element.survey_version_id = @survey_version.id

    # This sets a virtual attribute on each choice question's question content in order to create the correct name for display fields in the
    # after_create observer to get around the issue of the choice questions being saved before the matrix question's question content is saved
    # in the transaction.  This was causing matrix_question.statement to return an error in the after_create observer
    @matrix_question.choice_questions.each do |cq|
      cq.question_content.matrix_statement = @matrix_question.question_content.try(:statement)
    end

    respond_to do |format|
      if @matrix_question.save
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added Matrix question."}
      else
        format.html {render :new }
      end
      format.js { render :partial => "shared/element_create", :object => @matrix_question, :as => :element }
    end
  end

  def edit
    @matrix_question = @survey_version.matrix_questions.includes(:choice_questions => [:question_content, :choice_answers]).find(params[:id])

    respond_to do |format|
      format.html #
      format.js
    end
  end

  def update
    choice_questions = params[:matrix_question][:choice_questions_attributes]

    choice_answer_attributes = params[:choice_answer_attributes] || {}
    choice_questions.each {|key, value| value.merge!({:choice_answers_attributes => choice_answer_attributes, :answer_type => "radio"})}

    @matrix_question = MatrixQuestion.find(params[:id])

    choice_questions.each {|key, value| value['question_content_attributes'].merge!(:matrix_statement => @matrix_question.question_content.try(:statement))}

    to_be_removed = choice_questions.select {|k, value| value[:question_content_attributes][:_destroy] == "1" }
    to_be_removed.each {|key, choice_question_params| remove_sub_question_display_field_and_rules(@matrix_question, choice_question_params)}

    respond_to do |format|
      if @matrix_question.update_attributes(params[:matrix_question])
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added Matrix question."}
      else
        format.html {render :partial => 'new_matrix_question', :locals => {:survey => @survey_version.survey, :survey_version => @survey_version} }
      end
      format.js { render :partial => "shared/element_create", :object => @matrix_question, :as => :element }
    end
  end

  def destroy
    @matrix_question = @survey_version.matrix_questions.find(params[:id])

    destroy_default_rule_and_display_field(@matrix_question)
    @matrix_question.destroy

    respond_to do |format|
      format.html { redirect_to [@survey, @survey_version] , :notice => "Successfully deleted Matrix question."}
      format.js { render :partial => "shared/element_destroy" }
    end
  end

  private
  def remove_sub_question_display_field_and_rules(matrix_question, choice_question_params)
    matrix_statement = matrix_question.question_content.statement_changed? ? matrix_question.question_content.statement_was : matrix_question.question_content.statement

    name = "#{matrix_statement}: #{choice_question_params[:question_content_attributes][:statement]}"

    rule = matrix_question.survey_version.rules.find_by_name(name)
    rule.destroy if rule.present?
    Rails.logger.debug "Removing rule: #{name}"

    df = matrix_question.survey_version.display_fields.find_by_name(name)
    df.destroy if df.present?
    Rails.logger.debug "Removing DispalyField: #{name}"

  end

  def get_survey_and_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end

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
