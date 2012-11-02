class RulesController < ApplicationController
  before_filter :get_survey_version, :except=>[:do_now, :check_do_now]

  def index
    @rules = @survey_version.rules.order(:rule_order)
  end

  def show
    @rule = @survey_version.rules.find(params[:id])
  end

  def new
    @rule = @survey_version.rules.build
    build_source_array
    do_rule_builds
  end

  def create
    build_source_array
    @rule = @survey_version.rules.build params[:rule]
    @rule.rule_order = @survey_version.rules.count + 1

    if @rule.save
      redirect_to [@survey, @survey_version,@rule], :notice  => "Successfully created rule."
    else
      do_rule_builds
      render :new
    end
  end

  def edit
    @rule = @survey_version.rules.find(params[:id])
    build_source_array
    do_rule_builds
  end

  def update
    @rule = @survey_version.rules.find(params[:id])

    if @rule.update_attributes(params[:rule])
      redirect_to survey_survey_version_rule_path(@survey, @survey_version, @rule), :notice  => "Successfully updated rule."
    else
      build_source_array
      do_rule_builds
      render :edit
    end
  end

  def destroy
    @rule = @survey_version.rules.find(params[:id])

    @rule.destroy

    redirect_to survey_survey_version_rules_path(@survey, @survey_version), :notice  => "Successfully deleted rule."
  end

  def do_now
    @rule = Rule.find(params[:id])
    @job_id = @rule.delay.apply_me_all

    render :text => @job_id.id
  end

  def check_do_now
    render :text => (Delayed::Job.exists?(params[:job_id]) ? "not done" : "done")
  end

  def increment_rule_order
    @rule = @survey_version.rules.find(params[:id])
    @rule.increment_rule_order

    redirect_to survey_survey_version_rules_path, :notice => "Successfully updated rule order"
  end

  def decrement_rule_order
    @rules = @survey_version.rules.find(params[:id])
    @rules.decrement_rule_order

    redirect_to survey_survey_version_rules_path, :notice => "Successfully updated rule order"
  end

  private
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end

  def do_rule_builds
    @rule.execution_trigger_rules.build if  @rule.execution_trigger_rules.size == 0
    @rule.actions.build if @rule.actions.size == 0
    @rule.criteria.build if @rule.criteria.size == 0
  end

  def build_source_array
    @source_array = @survey_version.sources
    @source_array.concat(@survey_version.display_fields.collect {|df| ["#{df.id},#{df.type}", df.name + "(display field)"]})
  end
end
