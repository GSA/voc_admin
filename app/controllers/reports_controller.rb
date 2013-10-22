# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the Report lifecycle.
class ReportsController < ApplicationController
  before_filter :get_survey_version
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
    @text_question_reporters = TextQuestionReporter.where(sv_id: @survey_version.id)
    @choice_question_reporters = ChoiceQuestionReporter.where(sv_id: @survey_version.id)
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

  private

  def get_report
    @report = @survey_version.reports.find(params[:id])
  end
end
