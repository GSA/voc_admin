class QuestionBanksController < ApplicationController
  def show
    if params[:survey_version_id]
      @survey_version = SurveyVersion.find params[:survey_version_id]
      @page = @survey_version.pages.find params[:page_id] if params[:page_id]
    end

    @question_bank = QuestionBank.instance
  end

  def add_question_to_survey
    @survey_version = SurveyVersion.find params[:survey_version_id]
    @page = @survey_version.pages.find params[:page_id]

    if !%w(TextQuestion ChoiceQuestion MatrixQuestion).include?(params[:question_type])
      raise ActiveRecord::RecordNotFound
    end

    @question = params[:question_type].classify.constantize.find params[:question_id].to_i

    survey_element = @question.build_survey_element(
      page: @page,
      survey_version: @survey_version
    )
    survey_element.send(:set_element_order)

    @cloned_question = @question.clone_me(@survey_version, @page, false)

    respond_to do |format|
      format.js { render :partial => "shared/element_create", :object => @cloned_question, :as => :element }
    end
  end
end
