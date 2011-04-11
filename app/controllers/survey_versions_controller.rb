class SurveyVersionsController < ApplicationController
  
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
