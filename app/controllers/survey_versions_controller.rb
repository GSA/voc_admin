# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the SurveyVersion lifecycle.
class SurveyVersionsController < ApplicationController
  before_filter :get_survey

  # GET    /surveys/:survey_id/survey_versions(.:format)
  def index
    @survey_versions = @survey.survey_versions.get_unarchived.order(order_clause(params[:sort], params[:direction])).page(params[:page]).per(10)
    respond_to do |format|
      format.html #
      format.js {render :json => [{:value => 0, :display => "Choose a version"}].concat(@survey.survey_versions.get_unarchived.order("major desc, minor desc").collect {|s| {:value => s.id, :display => s.version_number}}) }
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:id(.:format)
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

  # GET    /surveys/:survey_id/survey_versions/:id/edit(.:format)
  def edit
    redirect_to surveys_path, :flash => {:notice => "The survey you are trying to access has been removed"} if @survey.archived || @survey_version.archived
    redirect_to survey_survey_versions_path(@survey), :flash => {:notice => "You may not edit a survey once it has been published.  Please create a new version if you wish to make changes to this survey"} if @survey_version.locked
  end

  # GET    /surveys/:survey_id/survey_versions/:id/edit_thank_you_page(.:format)
  def edit_thank_you_page
  end

  # PUT    /surveys/:survey_id/survey_versions/:id(.:format)
  def update
    if @survey_version.update_attributes params[:survey_version].slice("thank_you_page")
      redirect_to survey_survey_versions_path(@survey), :notice => "Successfully updated the thank you page"
    else
      render :edit
    end
  end

  # DELETE /surveys/:survey_id/survey_versions/:id(.:format)
  def destroy
    @survey_version.update_attribute(:archived, true)
    respond_to do |format|
      format.html { redirect_to(survey_survey_versions_path(@survey_version.survey), :notice => 'Survey Version was successfully deleted.') }
      format.xml  { head :ok }
    end
  end

  # GET    /surveys/:survey_id/survey_versions/create_new_major_version(.:format)
  def create_new_major_version
    @survey.create_new_major_version
    respond_to do |format|
      format.html { redirect_to(survey_survey_versions_path(@survey), :notice => 'Major Survey Version was successfully created.') }
      format.xml  { head :ok }
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:id/publish(.:format)
  def publish
    if @survey_version.questions.empty?
      redirect_to survey_survey_versions_path(@survey), :flash => {:error => "Cannot publish an empty survey."}
    else
      @survey_version.publish_me
      Rails.cache.clear if Rails.cache
      redirect_to survey_survey_versions_path(@survey), :notice => "Successfully published survey version."
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:id/unpublish(.:format)
  def unpublish
    @survey_version.unpublish_me
    redirect_to survey_survey_versions_path(@survey), :notice => "Successfully unpublished survey version"
  end

  # GET    /surveys/:survey_id/survey_versions/:id/clone_version(.:format)
  def clone_version
    @minor_version = @survey_version.clone_me

    redirect_to survey_survey_versions_path(@survey), :notice => "Successfully cloned new minor version"
  end

  private

  # Prepares the survey and survey version instance. This is a one-off from the
  # ApplicationController definition due to the :id parameter.
  def get_survey
    @survey = @current_user.surveys.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:id]) if params[:id]
  end

  # Generates a clause string ready to be passed to #order(). Parameters are
  # optional but will not generate sane content if omitted.
  #
  # @param [String] column the column name to sort by
  # @param [String] direction the direction string to apply
  def order_clause(column = nil, direction = nil)
    dir = sort_direction(direction)
    col = sort_column(column)

    if col == "major, minor"
      col.split(",").map {|c| "#{c} #{dir}" }.join(",")
    else
      "#{col} #{dir}"
    end
  end

  # Allows sorting on a specific set of SurveyVersion columns. Defaults to
  # major and minor survey version if not specified or unexpected value.
  #
  # @param [String] column the column name to sort by
  # @return [String] "asc" or "desc"
  def sort_column(column = "major, minor")
    columns = ["major, minor", "published", "created_at", "updated_at"]
    columns.include?(column) ? column : "major, minor"
  end

  # Allows sort directions of ascending or descending.
  # Defaults to ascending if not specified or unexpected value.
  #
  # @param [String] direction direction to sort by
  # @return [String] "asc" or "desc"
  def sort_direction(direction = "asc")
    directions = %w(asc desc)
    directions.include?(direction) ? direction : "asc"
  end

end
