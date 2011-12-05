class PagesController < ApplicationController
  before_filter :get_survey, :get_survey_version
  
  def create
    @page = @survey_version.pages.build params[:page]
    
    respond_to do |format|
      if @page.save
        format.js {render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version, :survey => @survey}}
      else
        format.js {render :partial => "shared/question_errors", :locals => {:object => @page}}
      end
    end
  end
  
  def update
    @page = @survey_version.pages.find(params[:id])
    
    respond_to do |format|
      if @page.update_attributes(params[:page])
        format.js { render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version, :survey => @survey} }
      else
        format.js { render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version, :survey => @survey}, :status => 500 }
      end
    end
  end
  
  def move_page
    @page = @survey_version.pages.find(params[:id])
    @target_page = params[:page_number]
    
    @page.move_page_to(@target_page)
    
    respond_to do |format|
      format.js { render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version, :survey => @survey} }
    end
  end
  
  def destroy
    @page = @survey_version.pages.find(params[:id])
    @page.destroy
  
    respond_to do |format|
      format.js   { render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version, :survey => @survey} }
    end
  end
  
  def copy_page
    page = @survey_version.pages.find(params[:id])
    page.create_copy
    respond_to do |format|
      format.js   { render :partial => "survey_versions/question_list", :locals => {:survey_version => @survey_version, :survey => @survey} }
    end
  end
  
  private
  def get_survey
    @survey = Survey.find(params[:survey_id])
  end
  def get_survey_version
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end
    
end
