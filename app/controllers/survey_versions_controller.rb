class SurveyVersionsController < ApplicationController
  
  def new
    @survey_version = SurveyVersion.new
  end
  
  def create
    @survey_version = SurveyVersion.new(params[:survey_version])
    @survey_version.major = 1
    @survey_version.minor = 0
    if @survey_version.save
      redirect_to survey_path(@survey_version.survey.id)
    else
      render :action => :new
    end
  end
  
  def edit
    @survey_version = SurveyVersion.find(params[:id])
  end
  
  def update
    @survey_version = SurveyVersion.find(params[:id])
    
    if @survey_version.update_attributes(params[:survey_version])
      redirect_to @survey_version
    else
      render :action => :edit
    end
  end
end
