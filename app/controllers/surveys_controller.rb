class SurveysController < ApplicationController
  # GET /surveys
  # GET /surveys.xml
  def index
    @surveys = Survey.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @surveys }
    end
  end

  # GET /surveys/1
  # GET /surveys/1.xml
  def show
    @survey = Survey.find(params[:id])
    @survey_version = params[:version].blank? ? @survey.newest_version : get_survey_version(@survey, params[:version])
    
    respond_to do |format|
      format.html # show.html.erb
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
    @version = @survey.survey_versions.build
    
    @version.major = 1
    @version.minor = 0
    @version.published = false
    
    # first_page = @version.pages.build
    # first_page.number = 1
    
    respond_to do |format|
      if @survey.save  # Will save both survey and survey_version and run validations on both
        format.html { redirect_to(edit_survey_path(@survey), :notice => 'Survey was successfully created.') }
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
    @survey.destroy

    respond_to do |format|
      format.html { redirect_to(surveys_url) }
      format.xml  { head :ok }
    end
  end
  
  
  private
  def get_survey_version(survey, version)
    major, minor = version.split('.')
    @survey_version = survey.survey_versions.where(:major => major, :minor => minor).first
  end
end
