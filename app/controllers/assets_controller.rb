class AssetsController < ApplicationController
  before_filter :get_survey_version
  
  def new
    @asset = @survey_version.assets.build
    
    respond_to do |format|
      format.html #
      format.js
    end
  end
  
  def create
    @asset = Asset.new(params[:asset])
    @asset.survey_element.survey_version_id = @survey_version.id
    
    respond_to do |format|
      if @asset.save
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
        format.js
      else
        format.html {render :action => 'new'}
        format.js
      end
    end  
  end
  
  def edit
    @asset = @survey_version.assets.find(params[:id])
    
    respond_to do |format|
      format.html #
      format.js
    end
  end

  def update
    #@asset = @survey_version.assets.find(params[:id])
    @asset = Asset.find(params[:id])
    
    respond_to do |format|
      if @asset.update_attributes(params[:asset])
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
        format.js   {render :create }
      else
        format.html {render :action => 'edit'}
        format.js   {render :create }
      end
    end
  end

  def destroy
    @asset = @survey_version.assets.find(params[:id])
    @asset.destroy
    
    respond_to do |format|
      format.html { redirect_to text_questions_url, :notice => "Successfully deleted text question."}
      format.js
    end
  end

  private
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = SurveyVersion.find(params[:survey_version_id])
  end
  
end
