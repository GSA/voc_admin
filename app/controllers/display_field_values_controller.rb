# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the lifecycle of DisplayFieldValues (modal edit
# from the SurveyResponse grid.)
class DisplayFieldValuesController < ApplicationController
  before_filter :get_survey_version

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/display_field_values/:id/edit(.:format)
  def edit
    @display_field_value = DisplayFieldValue.find(params[:id])

    respond_to do |format|
      format.html #
      format.js    { render :edit}
    end
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/display_field_values/:id(.:format)
  def update
    @display_field_value = DisplayFieldValue.find(params[:id])

    respond_to do |format|
      if @display_field_value.update_attributes(display_field_value_attributes)

        # Reprocess response when a field is updated
        @display_field_value.survey_response.async(:process_me, 2)

        format.html {redirect_to root_url, :notice  => "Successfully updated display field."}
        format.js
        format.json { head :ok }
      else
        format.html {render :action => 'edit'}
        format.js   { render :edit }
        format.json { render :json => @display_field_value.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  private

  def display_field_value_attributes
    params.require(:display_field_value).permit(:value)
  end
end
