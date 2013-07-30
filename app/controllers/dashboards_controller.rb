# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the Dashboard lifecycle.
class DashboardsController < ApplicationController
  before_filter :get_survey_version
  before_filter :get_dashboard, except: [:new, :create]

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/new(.:format)
  def new
    @dashboard = @survey_version.dashboards.build
  end

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/dashboards(.:format)
  def create
    @dashboard = @survey_version.dashboards.build params[:dashboard]

    if @dashboard.save
      redirect_to survey_survey_version_dashboard_path(@survey, @survey_version, @dashboard), :notice  => "Successfully created dashboard."
    else
      render :new
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:id(.:format)
  def show
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:id/edit(.:format)
  def edit
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:id(.:format)
  def update
    if @dashboard.update_attributes(params[:dashboard])
      redirect_to survey_survey_version_dashboard_path(@survey, @survey_version, @dashboard), :notice  => "Successfully updated dashboard."
    else
      render :edit
    end
  end

  # DELETE /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:id(.:format)
  def destroy
    @dashboard.destroy

    redirect_to reporting_survey_survey_version_path(@survey, @survey_version), :notice  => "Successfully deleted dashboard."
  end

  private

  def get_dashboard
    @dashboard = @survey_version.dashboards.find(params[:id])
  end
end
