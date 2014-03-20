# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the lifecycle of Asset HTML snippet entities.
class AssetsController < ApplicationController
  before_filter :get_survey_version

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/assets/new(.:format)
  def new
    @asset = @survey_version.assets.build
    @page = Page.find_by_id(params[:page_id])

    respond_to do |format|
      format.html #
      format.js
    end
  end

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/assets(.:format)
  def create
    @asset = Asset.new(params[:asset])
    @asset.survey_element.survey_version_id = @survey_version.id

    respond_to do |format|
      if @asset.save
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added HTML snippet."}
      else
        format.html {render :action => 'new'}
      end
      format.js { render :partial => "shared/element_create", :object => @asset, :as => :element }
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/assets/:id/edit(.:format)
  def edit
    @asset = @survey_version.assets.find(params[:id])

    respond_to do |format|
      format.html #
      format.js
    end
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/assets/:id(.:format)
  def update
    @asset = Asset.find(params[:id])

    respond_to do |format|
      if @asset.update_attributes(params[:asset])
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully updated HTML snippet."}
      else
        format.html {render :action => 'edit'}
      end
      format.js { render :partial => "shared/element_create", :object => @asset, :as => :element }
    end
  end

  # DELETE /surveys/:survey_id/survey_versions/:survey_version_id/assets/:id(.:format)
  def destroy
    @asset = @survey_version.assets.find(params[:id])
    @asset.destroy

    respond_to do |format|
      format.html { redirect_to survey_path(@survey_version.survey), :notice => "Successfully deleted HTML snippet."}
      format.js { render :partial => "shared/element_destroy" }
    end
  end
end
