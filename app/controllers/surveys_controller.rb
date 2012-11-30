class SurveysController < ApplicationController
  # GET /surveys
  def index
    @surveys = current_user.surveys.search(params[:q]).order("surveys.#{sort_column} #{sort_direction}").page(params[:page]).per(10)
  end

  # GET /surveys/1
  def show
    @survey = current_user.surveys.find(params[:id])

  end

  # GET /surveys/new
  def new
    @survey = current_user.surveys.new

  end

  # POST /surveys
  def create
    @survey = current_user.surveys.new(params[:survey])

    if @survey.save  # Will save both survey and survey_version and run validations on both
      redirect_to([:edit, @survey, @survey.survey_versions.first], :notice => 'Survey was successfully created.')
    else
      render :action => "new"
    end
  end

  # GET /surveys/edit
  def edit
   @survey = current_user.surveys.find(params[:id])
  end

  # PUT /surveys/1
  def update
     @survey = current_user.surveys.find(params[:id])
     @survey.update_attributes(params[:survey])

     if @survey.update_attributes(params[:survey])
       redirect_to(surveys_url, :notice => "Survey was successfully updated.")
     else
       render :new
     end
   end

  # DELETE /surveys/1
  def destroy
    @survey = current_user.surveys.find(params[:id])
    @survey.update_attribute(:archived, true)


    redirect_to(surveys_url, :notice => 'Survey was successfully deleted.')
  end


  private
  def sort_column
    %w(name).include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w(asc desc).include?(params[:direction]) ? params[:direction] : "asc"
  end
end
