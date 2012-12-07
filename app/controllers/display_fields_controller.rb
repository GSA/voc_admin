# Manages the lifecycle of DisplayFields.
class DisplayFieldsController < ApplicationController
  before_filter :get_survey_version

  # Index.
  def index
    @display_fields = @survey_version.display_fields.order(:display_order)
  end

  # New.
  def new
    @display_field = @survey_version.display_fields.build
  end

  # Create.
  def create
    @display_field = @survey_version.display_fields.build params[:display_field]
    @display_field.type = params[:display_field][:model_type]
    @display_field.display_order = @survey_version.display_fields.maximum(:display_order).to_i + 1

    if @display_field.save
      redirect_to survey_survey_version_display_fields_path, :notice => "Successfully created display field."
    else
      render :new
    end
  end

  # Edit.
  def edit
    @display_field = DisplayField.find(params[:id])
    if !@display_field.editable?
      flash[:error] = "This display field can not be editted."
      redirect_to survey_survey_version_display_fields_path
    end
  end

  # Update.
  def update
    @display_field = DisplayField.find(params[:id])

    if @display_field.update_attributes(params[:display_field])
      redirect_to survey_survey_version_display_fields_path, :notice => "Successfully updated display field"
    else
      render :edit
    end
  end

  # Destroy.
  def destroy
    @display_field = @survey_version.display_fields.find(params[:id])

    if @display_field.editable?
      @display_field.destroy
      ## TODO: Re-order the display_field_order
      flash[:notice] = "Successfully deleted display field."
    else
      flash[:error] = "This display field can not be deleted."
    end

    redirect_to survey_survey_version_display_fields_path(@survey, @survey_version)
  end

  # Moves the DisplayField down in the list.
  def increment_display_order
    @display_field = @survey_version.display_fields.find(params[:id])
    @display_field.increment_display_order

    redirect_to survey_survey_version_display_fields_path, :notice => "Successfully updated display field order"
  end

  # Moves the DisplayField up in the list.
  def decrement_display_order
    @display_field = @survey_version.display_fields.find(params[:id])
    @display_field.decrement_display_order

    redirect_to survey_survey_version_display_fields_path, :notice => "Successfully updated display field order"
  end

  private
  
  # Load Survey and SurveyVersion information from the DB.
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end
end
