class AssetsController < ApplicationController
  before_filter :get_survey_version, :except => :destroy
  
  def new
    @asset = @survey_version.assets.build
    
    respond_to do |format|
      format.html #
      format.js { render :new }
    end
  end
  
  def create
    @asset = Asset.new(params[:asset])
    @asset.survey_element.survey_version_id = @survey_version.id
    
    respond_to do |format|
      if @asset.save
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
        format.js   {render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version}}
      else
        format.html {render :action => 'new'}
        format.js   {render :new, :status => 500}
      end
    end  
  end
  
  def edit
    @asset = @survey_version.assets.find(params[:id])
    
    respond_to do |format|
      format.html #
      format.js {render :action => :edit}
    end
  end

  def update
    @asset = Asset.find(params[:id])
    
    respond_to do |format|
      if @asset.update_attributes(params[:asset])
        format.html {redirect_to survey_path(@survey_version.survey), :notice => "Successfully added text question."}
        format.js   {render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version}}
      else
        format.html {render :action => 'edit'}
        format.js   {render :partial => "shared/question_errors", :locals => {:object => @choice_question}, :status => 500}
      end
    end
  end

  def destroy
    @asset = Asset.find(params[:id])
    @asset.destroy
    
    respond_to do |format|
      format.html { redirect_to text_questions_url, :notice => "Successfully deleted text question."}
      format.js   { render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version } }
    end
  end

  private
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = SurveyVersion.find(params[:survey_version_id])
  end
  
end
