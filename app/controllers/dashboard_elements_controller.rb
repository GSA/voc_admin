# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the Dashboard Element lifecycle.
class DashboardElementsController < ApplicationController
  before_filter :get_survey_version
  before_filter :get_dashboard
  before_filter :get_dashboard_element, except: [:new, :create]

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:dashboard_id/dashboard_elements/new(.:format)
  def new
    @dashboard_element = @dashboard.dashboard_elements.build
  end

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:dashboard_id/dashboard_elements(.:format)
  def create
    @dashboard_element = @dashboard.dashboard_elements.build params[:dashboard_element]

    if @dashboard_element.save
      redirect_to survey_survey_version_dashboard_path(@survey, @survey_version, @dashboard),
      			  :notice  => "Successfully created dashboard element."
    else
      render :new
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:dashboard_id/dashboard_elements/:id/edit(.:format)
  def edit
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:dashboard_id/dashboard_elements/:id(.:format)
  def update
    if @dashboard_element.update_attributes(params[:dashboard_element])
      redirect_to survey_survey_version_dashboard_path(@survey, @survey_version, @dashboard),
      			  :notice  => "Successfully updated dashboard element."
    else
      render :edit
    end
  end

  # DELETE /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:dashboard_id/dashboard_elements/:id(.:format)
  def destroy
    @dashboard_element.destroy

    redirect_to survey_survey_version_dashboard_path(@survey, @survey_version, @dashboard),
    			:notice  => "Successfully deleted dashboard element."
  end

  private

  def get_dashboard
    @dashboard = @survey_version.dashboards.find(params[:dashboard_id])
  end

  def get_dashboard_element
  	@dashboard_element = @dashboard.dashboard_elements.find(:id)
  end
end
