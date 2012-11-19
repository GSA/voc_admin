class CustomViewsController < ApplicationController
  before_filter :get_survey_version
  
  def index
    @custom_views = @survey_version.custom_views.all
  end

  def new
    @custom_view = @survey_version.custom_views.build
  end

  def create
    @custom_view = @survey_version.custom_views.build params[:custom_view]

    if @custom_view.save
      #redirect_to survey_survey_version_custom_views_path, :notice => "Successfully created custom view."
      redirect_to survey_responses_path(:survey_id => @survey.id, :survey_version_id => @survey_version.id, :custom_view_id => @custom_view.id), :notice => "Successfully created custom view."
    else
      render :new
    end
  end

  def edit
    @custom_view = CustomView.find(params[:id])
  end

  def update
    @custom_view = CustomView.find(params[:id])

    if @custom_view.update_attributes(params[:custom_view])
      #redirect_to survey_survey_version_custom_views_path, :notice => "Successfully updated custom view"
      redirect_to survey_responses_path(:survey_id => @survey.id, :survey_version_id => @survey_version.id, :custom_view_id => @custom_view.id), :notice => "Successfully created custom view."
    else
      render :edit
    end
  end
  
  def destroy
    @custom_view = @survey_version.custom_views.find(params[:id])
    
    @custom_view.destroy
    flash[:notice] = "Successfully deleted custom view."

    redirect_to survey_responses_path(:survey_id => @survey.id, :survey_version_id => @survey_version.id), :notice => "Successfully removed custom view."
  end
  
  private
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end
end
