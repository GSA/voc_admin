# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the Survey lifecycle.
class SurveysController < ApplicationController
  include AkamaiUtilities

  before_filter :require_admin, only: :all_questions

  def preview
    @css_files = Dir.glob("public/stylesheets/custom/*.css").map {|stylesheet|
      PremadeCss.new(stylesheet)
    }
    @surveys = current_user.surveys.order(:name)
  end

  # GET    /surveys(.:format)
  def index
    @surveys = current_user.surveys.search(params[:q])
      .order("surveys.name #{sort_direction}").page(params[:page]).per(10)
    if @surveys.count == 0 && params[:q].present?
      flash.now[:notice] = "No surveys were found with search."
    end
  end

  # GET    /surveys/new(.:format)
  def new
    @survey = current_user.surveys.new
  end

  # POST   /surveys(.:format)
  def create
    @survey = current_user.surveys.new(params[:survey])
    @survey.created_by_id = @current_user.id

    # Will save both survey and survey_version and run validations on both
    if @survey.save
      redirect_to([:edit, @survey, @survey.survey_versions.first],
                  :notice => 'Survey was successfully created.')
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

    if @survey.update_attributes(params[:survey])
      flush_akamai(@survey.flushable_urls) if @survey.published_version
      redirect_to(surveys_url, :notice => "Survey was successfully updated.")
    else
      render :edit
    end
  end

  # DELETE /surveys/:id(.:format)
  def destroy
    @survey = current_user.surveys.find(params[:id])
    @survey.update_attribute(:archived, true)

    redirect_to(surveys_url, :notice => 'Survey was successfully deleted.')
  end

  def start_page_preview
    @survey = current_user.surveys.find params[:id]
    render layout: 'empty'
  end

  def all_questions
    @published_versions = SurveyVersion.includes(:survey).where(published: true, surveys: { archived: false } )
  end

  def import_survey_version
    @survey = Survey.find(params[:survey_id])
    if params[:file].present?
      if @survey.import_survey_version(params[:file], current_user.id)
        redirect_to(survey_survey_versions_path(@survey),
          :notice => 'Survey Version was imported successfully.')
      else
        redirect_to survey_survey_versions_path(@survey),
          alert: "Unable to import file.  Please make sure you are importing a survey export file"
      end
    else
      redirect_to survey_survey_versions_path(@survey),
        :alert => "Please select a file before clicking the import button."
    end
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
