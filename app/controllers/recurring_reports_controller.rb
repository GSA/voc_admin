# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the Report lifecycle.
class RecurringReportsController < ApplicationController
  before_filter :get_survey_version, :get_report
  before_filter :get_recurring_report, except: [:index, :new, :create]

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/reports/:report_id/recurring_reports/new(.:format)
  def new
    @recurring_report = @report.recurring_reports.build
  end

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/reports/:report_id/recurring_reports(.:format)
  def create
    params[:recurring_report][:user_created_by_id] = current_user.id
    params[:recurring_report][:pdf] ||= "false"
    @recurring_report = @report.recurring_reports.build params[:recurring_report]

    if @recurring_report.save
      redirect_to survey_survey_version_report_recurring_reports_path(@survey, @survey_version, @report), :notice  => "Successfully created recurring report."
    else
      render :new
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/reports/:report_id/recurring_reports/:id(.:format)
  def show
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/reports/:report_id/recurring_reports/:id/edit(.:format)
  def edit
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/reports/:report_id/recurring_reports/:id(.:format)
  def update
    params[:recurring_report][:user_last_modified_by_id] = current_user.id
    if @recurring_report.update_attributes(params[:recurring_report])
      redirect_to survey_survey_version_report_recurring_reports_path(@survey, @survey_version, @report), :notice  => "Successfully updated recurring report."
    else
      render :edit
    end
  end

  # DELETE /surveys/:survey_id/survey_versions/:survey_version_id/reports/:report_id/recurring_reports/:id(.:format)
  def destroy
    @recurring_report.destroy

    redirect_to survey_survey_version_report_recurring_reports_path(@survey, @survey_version, @report), :notice  => "Successfully deleted recurring report."
  end

  private

  def get_report
    @report = @survey_version.reports.find(params[:report_id])
  end

  def get_recurring_report
    @recurring_report = @report.recurring_reports.find(params[:id])
  end
end
