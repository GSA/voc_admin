# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the Report lifecycle.
class ReportsController < ApplicationController
  skip_before_filter :require_user, :login_required, :authenticate_user!, only: :pdf
  before_filter :require_token_or_user, :get_survey_version_with_token, only: :pdf
  before_filter :get_survey_version, except: :pdf
  before_filter :get_report, except: [:new, :create]

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/reports/new(.:format)
  def new
    @report = @survey_version.reports.build
  end

  # POST   /surveys/:survey_id/survey_versions/:survey_version_id/reports(.:format)
  def create
    @report = @survey_version.reports.build report_params

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
    if @report.update_attributes(report_params)
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
    ReportsMailer.async(:report_csv, @report.id, params[:emails], current_user.email, 'once')
    flash[:notice] = "Report CSV will be sent to: #{params[:emails]}"
    redirect_to survey_survey_version_report_path(@survey, @survey_version, @report)
  end

  def email_pdf
    ReportsMailer.async(:report_pdf, @report.id, params[:emails], current_user.email, 'once')
    flash[:notice] = "Report PDF will be sent to: #{params[:emails]}"
    redirect_to survey_survey_version_report_path(@survey, @survey_version, @report)
  end

  def question_csv
    respond_to do |format|
      format.csv do
        case params[:reporter_type]
        when 'text'
          send_data @report.text_question_csv(params[:reporter_id])
        when 'choice'
          send_data @report.choice_question_csv(params[:reporter_id])
        end
      end
    end
  end

  private

  def report_params
    params.require(:report).permit(
      :name, :survey_version_id, :start_date, :end_date,
      :limit_answers, report_elements_attributes: [
        :id,
        :"_destroy",
        :type,
        :report_id,
        :choice_question_id,
        :text_question_id,
        :matrix_question_id
      ]
    )
  end

  def get_report
    @report = @survey_version.reports.find(params[:id])
  end
end
