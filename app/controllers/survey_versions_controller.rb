class SurveyVersionsController < ApplicationController
  before_filter :get_survey
  
  def index
    @survey_versions = @survey.survey_versions.get_unarchived.order("major desc, minor desc").all
    respond_to do |format|
      format.html #
      format.js {render :json => [{:value => 0, :display => "Choose a version"}].concat(@survey_versions.collect {|s| {:value => s.id, :display => s.version_number}}) }
    end
  end
  
  def show
    respond_to do |format|
      if @survey.archived || @survey_version.archived
        flash[:error] = "The survey you are trying to access has been removed."
        format.html {redirect_to(surveys_path)}
      else
        format.html # show.html.erb
      end
    end
  end
  
  def edit
    respond_to do |format|
      if @survey.archived || @survey_version.archived
        flash[:error] = "The survey you are trying to access has been removed."
        format.html {redirect_to(surveys_path)}
      else
        format.html # edit.html.erb
      end
    end
  end
  
  def destroy
    @survey_version.update_attribute(:archived, true)
    respond_to do |format|
      format.html { redirect_to(survey_survey_versions_path(@survey_version.survey), :notice => 'Survey Version was successfully deleted.') }
      format.xml  { head :ok }
    end
  end
  
  def create_new_major_version
    @survey.create_new_major_version
    respond_to do |format|
      format.html { redirect_to(survey_survey_versions_path(@survey), :notice => 'Major Survey Version was successfully created.') }
      format.xml  { head :ok }
    end
  end
  
  def create_new_minor_version
    
    respond_to do |format|
      format.html { redirect_to(survey_survey_versions_path(@survey_version.survey), :notice => 'Minor Survey Version was successfully created.') }
      format.xml  { head :ok }
    end
  end
  
  def publish
    @survey_version.publish_me
    respond_to do |format|
      format.html { redirect_to(survey_survey_versions_path(@survey_version.survey)) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def get_survey
    @survey = Survey.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:id]) if params[:id]
  end
  
end
