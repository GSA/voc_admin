class SurveyElementsController < ApplicationController
  before_filter :get_survey_version

  def up
    @element = SurveyElement.find(params[:id])
    @element.move_element_up

    respond_to do |format|
      format.js { render "shared/update_question_list" }
    end
  end

  def down
    @element = SurveyElement.find(params[:id])
    @element.move_element_down

    respond_to do |format|
      format.js { render "shared/update_question_list" }
    end
  end
end
