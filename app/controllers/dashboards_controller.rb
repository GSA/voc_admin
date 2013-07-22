# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the Dashboard lifecycle.
class DashboardsController < ApplicationController
  before_filter :get_survey_version

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards(.:format)
  def index
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/new(.:format)
  def new
    @dashboard = @survey_version.dashboards.build
  end

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/dashboards(.:format)
  def create
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:id/edit(.:format)
  def edit
    @dashboard = Dashboard.find(params[:id])
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:id(.:format)
  def update
  end

  # DELETE /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:id(.:format)
  def destroy
  end
end
