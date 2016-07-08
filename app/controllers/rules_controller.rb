# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the lifecycle of Rule entities.
class RulesController < ApplicationController
  before_filter :get_survey_version, :except=>[:do_now, :check_do_now]

  # GET    /rules(.:format)
  def index
    @rules = @survey_version.rules.order(:rule_order)
  end

  # GET    /rules/:id(.:format)
  def show
    @rule = @survey_version.rules.find(params[:id])
  end

  # GET    /rules/new(.:format)
  def new
    @rule = @survey_version.rules.build
    build_source_array
    do_rule_builds
  end

  # POST   /rules(.:format)
  def create
    build_source_array
    @rule = @survey_version.rules.build rule_params
    @rule.rule_order = @survey_version.rules.count + 1

    if @rule.save
      redirect_to [@survey, @survey_version,@rule], :notice  => "Successfully created rule."
    else
      do_rule_builds
      render :new
    end
  end

  # GET    /rules/:id/edit(.:format)
  def edit
    @rule = @survey_version.rules.find(params[:id])
    build_source_array
    do_rule_builds
  end

  # PUT    /rules/:id(.:format)
  def update
    @rule = @survey_version.rules.find(params[:id])

    if @rule.update_attributes(rule_params)
      redirect_to survey_survey_version_rule_path(@survey, @survey_version, @rule), :notice  => "Successfully updated rule."
    else
      build_source_array
      do_rule_builds
      render :edit
    end
  end

  # DELETE /rules/:id(.:format)
  def destroy
    @rule = @survey_version.rules.find(params[:id])

    @rule.destroy

    redirect_to survey_survey_version_rules_path(@survey, @survey_version), :notice  => "Successfully deleted rule."
  end

  # GET    /surveys/:survey_id/survey_versions/:survey_version_id/rules/:id/do_now(.:format)
  def do_now
    @job_id = RuleJob.create(:id => params[:id])

    render :text => @job_id
  end

  # GET    /rules/check_do_now(.:format)
  def check_do_now
    render :text => Resque::Plugins::Status::Hash.get(params[:job_id]).status
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/rules/:id/increment_rule_order(.:format)
  def increment_rule_order
    @rule = @survey_version.rules.find(params[:id])
    @rule.increment_rule_order

    redirect_to survey_survey_version_rules_path, :notice => "Successfully updated rule order"
  end

  # PUT    /surveys/:survey_id/survey_versions/:survey_version_id/rules/:id/decrement_rule_order(.:format)
  def decrement_rule_order
    @rules = @survey_version.rules.find(params[:id])
    @rules.decrement_rule_order

    redirect_to survey_survey_version_rules_path, :notice => "Successfully updated rule order"
  end

  private

  # Ensures that the proper ExecutionTrigger joins, Actions, and Criteria are built
  # during Rule new/create/edit/update.
  def do_rule_builds
    @rule.execution_trigger_rules.build if  @rule.execution_trigger_rules.size == 0
    @rule.actions.build if @rule.actions.size == 0
    @rule.criteria.build if @rule.criteria.size == 0
  end

  # Combines SurveyVersion#sources with DisplayField information to populate the Rule sources drop-down.
  def build_source_array
    @source_array = @survey_version.sources
    @source_array.concat(@survey_version.display_fields.collect {|df| ["#{df.id},#{df.type}", df.name + "(display field)"]})
    @source_array << ["#{PageUrl::ID},PageUrl", PageUrl::DISPLAY_FIELD_HEADER]
  end

  def rule_params
    params.require(:rule).permit(
      :name, :action_type,
      criteria_attributes: [:source_select, :conditional_id, :value, :_destroy],
      email_action_attributes: [:emails, :subject, :body, :_destroy],
      actions_attributes: [:display_field_id, :value_type, :value, :_destroy],
      execution_trigger_ids: []
    )
  end
end
