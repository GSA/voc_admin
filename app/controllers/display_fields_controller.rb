class DisplayFieldsController < ApplicationController
  before_filter :get_survey_version
  
  def index
    @display_fields = @survey_version.display_fields
  end

  def new
    @display_field = @survey_version.display_fields.build
  end

  def create
    @display_field = @survey_version.display_fields.build params[:display_field]
    @display_field.type = params[:display_field][:type]
    @display_field.display_order = @survey_version.display_fields.count + 1

    if @display_field.save
      redirect_to survey_survey_version_display_fields_path
    else
      render :new
    end
  end
  
  def destroy
    @display_field = @survey_version.display_fields.find(params[:id])
    @display_field.destroy
    redirect_to survey_survey_version_display_fields_path(@survey, @survey_version)
  end
  
  private
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end
end
