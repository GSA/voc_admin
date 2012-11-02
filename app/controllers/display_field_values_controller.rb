class DisplayFieldValuesController < ApplicationController
  before_filter :get_survey_and_survey_version

  def edit
    @display_field_value = DisplayFieldValue.find(params[:id])

    respond_to do |format|
      format.html #
      format.js    { render :edit}
    end

  end

  def update
    @display_field_value = DisplayFieldValue.find(params[:id])

    respond_to do |format|
      if @display_field_value.update_attributes(params[:display_field_value])
        #@display_field_value.survey_response.process_me(2) # TODO: Reprocess response when a field is updated
        format.html {redirect_to root_url, :notice  => "Successfully updated display field."}
        format.js
      else
        format.html {render :action => 'edit'}
        format.js   { render :edit }
      end
    end
  end

  private
  def get_survey_and_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end
end
