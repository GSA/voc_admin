# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the lifecycle of DisplayFields.
class DisplayFieldsController < ApplicationController
  before_filter :get_survey_version

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/display_fields(.:format)
  def index
    @display_fields = @survey_version.display_fields.order(:display_order)
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/display_fields/new(.:format)
  def new
    @display_field = @survey_version.display_fields.build
  end

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/display_fields(.:format)
  def create
    @display_field = @survey_version.display_fields.build display_field_params
    @display_field.type = params[:display_field][:model_type]
    @display_field.display_order = @survey_version.display_fields.maximum(:display_order).to_i + 1

    if @display_field.save
      redirect_to survey_survey_version_display_fields_path, :notice => "Successfully created display field."
    else
      render :new
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/display_fields/:id/edit(.:format)
  def edit
    @display_field = DisplayField.find(params[:id])
    if !@display_field.editable?
      flash[:error] = "This display field can not be editted."
      redirect_to survey_survey_version_display_fields_path
    end
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/display_fields/:id(.:format)
  def update
    @display_field = DisplayField.find(params[:id])

    if @display_field.update_attributes(display_field_params)
      redirect_to survey_survey_version_display_fields_path, :notice => "Successfully updated display field"
    else
      render :edit
    end
  end

  # DELETE /surveys/:survey_id/survey_versions/:survey_version_id/display_fields/:id(.:format)
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

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/display_fields/:id/increment_display_order(.:format)
  # Moves the DisplayField down in the list.
  def increment_display_order
    @display_field = @survey_version.display_fields.find(params[:id])
    @display_field.increment_display_order

    redirect_to survey_survey_version_display_fields_path, :notice => "Successfully updated display field order"
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/display_fields/:id/decrement_display_order(.:format)
  # Moves the DisplayField up in the list.
  def decrement_display_order
    @display_field = @survey_version.display_fields.find(params[:id])
    @display_field.decrement_display_order

    redirect_to survey_survey_version_display_fields_path, :notice => "Successfully updated display field order"
  end

  private

  def display_field_params
    params.require(:display_field).permit(:name, :model_type, :default_value, :choices)
  end
end
