class SurveysController < ApplicationController
  # GET /surveys
  # GET /surveys.xml
  def index
    @surveys = Survey.get_unarchived.includes(:survey_type).order(:name).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @surveys }
    end
  end

  # GET /surveys/1
  # GET /surveys/1.xml
  def show
    @survey = Survey.find(params[:id])
    
    respond_to do |format|
      format.html {redirect_to(survey_survey_versions_path(@survey))}
      format.xml  { render :xml => @survey }
    end
  end

  # GET /surveys/new
  # GET /surveys/new.xml
  def new
    @survey = Survey.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @survey }
    end
  end

  # POST /surveys
  # POST /surveys.xml
  def create
    @survey = Survey.new(params[:survey])
    
    respond_to do |format|
      if @survey.save  # Will save both survey and survey_version and run validations on both
        format.html { redirect_to([:edit, @survey, @survey.survey_versions.first], :notice => 'Survey was successfully created.') }
        format.xml  { render :xml => @survey, :status => :created, :location => @survey }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey.errors, :status => :unprocessable_entity }
      end
    end
  end
  
 # GET /surveys/edit
 def edit
   @survey = Survey.find(params[:id])
   
   respond_to do |format|
     format.html # edit.html.erb
     format.xml { render :xml => @survey}
   end
 end
 
  def update
     @survey = Survey.find(params[:id])
     @survey.update_attributes(params[:survey])
       
     respond_to do |format|
       format.html { redirect_to(surveys_url, :notice => 'Survey was successfully updated.') }
       format.xml { render :xml => @survey}
     end
   end
#  
#  # POST /surveys/1
#  def update
#    @survey = Survey.find(params[:id])
#    
#    if @survey.update_attributes(params[:survey])
#      redirect_to survey_path(@survey)
#    else
#      render :action => :new
#    end
#  end

  # DELETE /surveys/1
  # DELETE /surveys/1.xml
  def destroy
    @survey = Survey.find(params[:id])
    @survey.update_attribute(:archived, true)

    respond_to do |format|
      format.html { redirect_to(surveys_url, :notice => 'Survey was successfully destroyed.') }
      format.xml  { head :ok }
    end
  end
  
  
  private
  def get_survey_version(survey, version)
    major, minor = version.split('.')
    @survey_version = survey.survey_versions.where(:major => major, :minor => minor).first
  end
end
