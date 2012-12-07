# Manages the lifecycle of Asset HTML snippet entities.
class AssetsController < ApplicationController
  before_filter :get_survey_version

  # New.
  def new
    @asset = @survey_version.assets.build

    respond_to do |format|
      format.html #
      format.js
    end
  end

  # Create.
  def create
    @asset = Asset.new(params[:asset])
    @asset.survey_element.survey_version_id = @survey_version.id

    respond_to do |format|
      if @asset.save
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
      else
        format.html {render :action => 'new'}
      end
      format.js { render :partial => "shared/element_create", :object => @asset, :as => :element }
    end
  end

  # Edit.
  def edit
    @asset = @survey_version.assets.find(params[:id])

    respond_to do |format|
      format.html #
      format.js
    end
  end

  # Update.
  def update
    @asset = Asset.find(params[:id])

    respond_to do |format|
      if @asset.update_attributes(params[:asset])
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
      else
        format.html {render :action => 'edit'}
      end
      format.js { render :partial => "shared/element_create", :object => @asset, :as => :element }
    end
  end

  # Destroy.
  def destroy
    @asset = @survey_version.assets.find(params[:id])
    @asset.destroy

    respond_to do |format|
      format.html { redirect_to text_questions_url, :notice => "Successfully deleted text question."}
      format.js { render :partial => "shared/element_destroy" }
    end
  end

  private

  # Load Survey and SurveyVersion information from the DB.
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = SurveyVersion.find(params[:survey_version_id])
  end
end
