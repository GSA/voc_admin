# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the lifecycle of SurveyResponse CustomViews.
class CustomViewsController < ApplicationController
  before_filter :get_survey_version

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/custom_views(.:format)
  def index
    @custom_views = @survey_version.custom_views.all
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/custom_views/new(.:format)
  def new
    @custom_view = @survey_version.custom_views.build
  end

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/custom_views(.:format)
  def create
    @custom_view = @survey_version.custom_views.build params[:custom_view]

    if @custom_view.save
      #redirect_to survey_survey_version_custom_views_path, :notice => "Successfully created custom view."
      redirect_to survey_responses_path(:survey_id => @survey.id, :survey_version_id => @survey_version.id, :custom_view_id => @custom_view.id), :notice => "Successfully created custom view."
    else
      set_display_fields_on_error
      render :new
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/custom_views/:id/edit(.:format)
  def edit
    @custom_view = CustomView.find(params[:id])
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/custom_views/:id(.:format)
  def update
    @custom_view = CustomView.find(params[:id])

    if @custom_view.update_attributes(params[:custom_view])
      #redirect_to survey_survey_version_custom_views_path, :notice => "Successfully updated custom view"
      redirect_to survey_responses_path(:survey_id => @survey.id, :survey_version_id => @survey_version.id, :custom_view_id => @custom_view.id), :notice => "Successfully created custom view."
    else
      set_display_fields_on_error
      render :edit
    end
  end

  # DELETE /surveys/:survey_id/survey_versions/:survey_version_id/custom_views/:id(.:format)
  def destroy
    @custom_view = @survey_version.custom_views.find(params[:id])

    @custom_view.destroy
    flash[:notice] = "Successfully deleted custom view."

    redirect_to survey_responses_path(:survey_id => @survey.id, :survey_version_id => @survey_version.id), :notice => "Successfully removed custom view."
  end

  private
  def set_display_fields_on_error
    @display_fields = params[:custom_view].
        try(:[], :ordered_display_fields).
        try(:[], :selected).
        try(:split, ',').
        try(:map) {|id| @survey_version.display_fields.find(id)}
  end
end
