# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the Dashboard lifecycle.
class DashboardsController < ApplicationController
  before_filter :get_survey_version
  before_filter :get_dashboard, except: [:new, :create]
  before_filter :update_sort_order, only: [:update]

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/new(.:format)
  def new
    @dashboard = @survey_version.dashboards.build
  end

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/dashboards(.:format)
  def create
    @dashboard = @survey_version.dashboards.build dashboard_params

    if @dashboard.save
      redirect_to survey_survey_version_dashboard_path(@survey, @survey_version, @dashboard),
        :notice  => "Successfully created dashboard."
    else
      render :new
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:id(.:format)
  def show
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/pdf/:id(.:format)
  def pdf
    render 'show', layout: 'pdf', formats: ['html']
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:id/edit(.:format)
  def edit
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/dashboards/:id(.:format)
  def update
    if @dashboard.update_attributes(dashboard_params)
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
  
  def dashboard_params
    params.require(:dashboard).permit(
      :name,
      :start_date,
      :end_date,
      dashboard_elements_attributes: [
        :id,
        :"_destroy",
        :survey_element_id,
        :sort_order_position,
        :display_type
      ]
    )
  end

  def get_dashboard
    @dashboard = @survey_version.dashboards.find(params[:id])
  end

  def update_sort_order
    if params[:dashboard].try(:[], :dashboard_elements_attributes).try(:empty?) == false
      params[:dashboard][:dashboard_elements_attributes].each_with_index do |arr, index|
        arr[1][:sort_order_position] = index
      end
    end
  end
end
