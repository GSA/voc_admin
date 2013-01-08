# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the Survey lifecycle.
class SurveysController < ApplicationController
  # GET    /surveys(.:format)
  def index
    @surveys = current_user.surveys.search(params[:q]).order("surveys.name #{sort_direction}").page(params[:page]).per(10)
  end

  # GET    /surveys/new(.:format)
  def new
    @survey = current_user.surveys.new
  end

  # POST   /surveys(.:format)
  def create
    @survey = current_user.surveys.new(params[:survey])

    if @survey.save  # Will save both survey and survey_version and run validations on both
      redirect_to([:edit, @survey, @survey.survey_versions.first], :notice => 'Survey was successfully created.')
    else
      render :action => "new"
    end
  end

  # GET    /surveys/:id/edit(.:format)
  def edit
   @survey = current_user.surveys.find(params[:id])
  end

  # PUT    /surveys/:id(.:format)
  def update
     @survey = current_user.surveys.find(params[:id])
     @survey.update_attributes(params[:survey])

     if @survey.update_attributes(params[:survey])
       redirect_to(surveys_url, :notice => "Survey was successfully updated.")
     else
       render :new
     end
   end

  # DELETE /surveys/:id(.:format)
  def destroy
    @survey = current_user.surveys.find(params[:id])
    @survey.update_attribute(:archived, true)

    redirect_to(surveys_url, :notice => 'Survey was successfully deleted.')
  end

  private

  # Allows sorting by survey name alphabetically ascending or descending.
  # Defaults to ascending if not specified or unexpected value.
  #
  # @return [String] "asc" or "desc"
  def sort_direction
    %w(asc desc).include?(params[:direction]) ? params[:direction] : "asc"
  end
end
