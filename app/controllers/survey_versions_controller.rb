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
    redirect_to surveys_path, :flash => {:notice => "The survey you are trying to access has been removed"} if @survey.archived || @survey_version.archived
    redirect_to survey_survey_versions_path(@survey), :flash => {:notice => "You may not edit a survey once it has been published.  Please create a new version if you wish to make changes to this survey"} if @survey_version.locked
  end

  def edit_thank_you_page
  end

  def update
    if @survey_version.update_attributes params[:survey_version].slice("thank_you_page")
      redirect_to survey_survey_versions_path(@survey), :notice => "Successfully updated the thank you page"
    else
      render :edit
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
    if @survey_version.questions.empty?
      redirect_to survey_survey_versions_path(@survey), :flash => {:error => "Cannot publish an empty survey."}
    else
      @survey_version.publish_me
      Rails.cache.clear if Rails.cache
      redirect_to survey_survey_versions_path(@survey), :notice => "Successfully published survey version."
    end
  end
  
  def unpublish
    @survey_version.unpublish_me
    redirect_to survey_survey_versions_path(@survey), :notice => "Successfully unpublished survey version"
  end
  
  def clone_version
    @minor_version = @survey_version.clone_me

    redirect_to survey_survey_versions_path(@survey), :notice => "Successfully cloned new minor version"

  end
  
  private
  
  def get_survey
    @survey = @current_user.surveys.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:id]) if params[:id]
  end
  
end
