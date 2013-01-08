# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Endpoints to move a SurveyElement up or down on a Page of a SurveyVersion.
class SurveyElementsController < ApplicationController
  before_filter :get_survey_version

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/survey_elements/:id/up(.:format)
  def up
    @element = SurveyElement.find(params[:id])
    @element.move_element_up

    respond_to do |format|
      format.js { render "shared/update_question_list" }
    end
  end

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/survey_elements/:id/down(.:format)
  def down
    @element = SurveyElement.find(params[:id])
    @element.move_element_down

    respond_to do |format|
      format.js { render "shared/update_question_list" }
    end
  end
end
