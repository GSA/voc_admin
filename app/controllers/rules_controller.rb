class RulesController < ApplicationController
  before_filter :get_survey_version
  
  def index
    @rules = @survey_version.rules
  end

  def show
    @rule = @survey_version.rules.find(params[:id])
  end
  
  def new
    @rule = @survey_version.rules.build
    @source_array = @survey_version.questions.collect {|q| ["#{q.assetable_id},#{q.assetable_type}", q.assetable.question_content.statement + "(question)"]}
    @source_array.concat(@survey_version.display_fields.collect {|df| ["#{df.id},#{df.type}", df.name + "(display field)"]})
  end
  
  def create
    @rule = @survey_version.rules.build params[:rule]
    @rule.rule_order = @survey_version.rules.count + 1
    
    if @rule.save
      redirect_to [@survey, @survey_version,@rule]
    else
      render :new
    end
  end
  
  def edit
    @rule = @survey_version.rules.find(params[:id])
    @source_array = @survey_version.questions.collect {|q| ["#{q.assetable_id},#{q.assetable_type}", q.assetable.question_content.statement + "(question)"]}
  end
  
  def update
    @rule = @survey_version.rules.find(params[:id])
    
    if @rule.update_attributes(params[:rule])
      redirect_to survey_survey_version_rule_path(@rule)
    else
      render :edit
    end
  end
  
  def destroy
    @rule = @survey_version.rules.find(params[:id])
    
    @rule.destroy
    
    redirect_to survey_survey_version_rules_path(@survey, @survey_version)
  end
  
  private
  def get_survey_version
    @survey = Survey.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end
end
