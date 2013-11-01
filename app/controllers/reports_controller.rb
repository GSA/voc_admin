# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the Report lifecycle.
class ReportsController < ApplicationController
  skip_before_filter :require_user, only: :pdf
  before_filter :require_token_or_user, :get_survey_version_with_token, only: :pdf
  before_filter :get_survey_version, except: :pdf
  before_filter :get_report, except: [:new, :create]

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/reports/new(.:format)
  def new
    @report = @survey_version.reports.build
  end

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/reports(.:format)
  def create
    @report = @survey_version.reports.build params[:report]

    if @report.save
      redirect_to survey_survey_version_report_path(@survey, @survey_version, @report), :notice  => "Successfully created report."
    else
      render :new
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/reports/:id(.:format)
  def show
    respond_to do |format|
      format.html
      format.csv { send_data @report.to_csv }
    end
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/reports/pdf/:id(.:format)
  def pdf
    render 'show', layout: 'pdf'
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/reports/:id/edit(.:format)
  def edit
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/reports/:id(.:format)
  def update
    if @report.update_attributes(params[:report])
      redirect_to survey_survey_version_report_path(@survey, @survey_version, @report), :notice  => "Successfully updated report."
    else
      render :edit
    end
  end

  # DELETE /surveys/:survey_id/survey_versions/:survey_version_id/reports/:id(.:format)
  def destroy
    @report.destroy

    redirect_to reporting_survey_survey_version_path(@survey, @survey_version), :notice  => "Successfully deleted report."
  end

  def email_csv
    ReportsMailer.async(:report_csv, @report.id, params[:emails], current_user.email)
    flash[:notice] = "Report CSV will be sent to: #{params[:emails]}"
    redirect_to survey_survey_version_report_path(@survey, @survey_version, @report)
  end

  def email_pdf
    url = survey_survey_version_pdf_report_url(@survey, @survey_version, @report, :format => :pdf)
    ReportsMailer.async(:report_pdf, @report.id, url, params[:emails], current_user.email)
    flash[:notice] = "Report PDF will be sent to: #{params[:emails]}"
    redirect_to survey_survey_version_report_path(@survey, @survey_version, @report)
  end

  private

  def get_report
    @report = @survey_version.reports.find(params[:id])
  end
end
