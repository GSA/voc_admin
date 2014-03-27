require 'benchmark'

desc "Recreate missing display fields."
task :recreate_display_fields => [:environment] do
  logger = Logger.new('recreate_display_fields.log')

  logger.info Benchmark.measure {
    missing_display_field_count = 0
    new_display_fields = []
    rules = []
    survey_versions = []
    surveys = []

    QuestionContent.where(nil).each do |qc|
      question_helper = QuestionHelper.new(qc, logger)
      if question_helper.missing_display_field?
        logger.info "#{qc.questionable_type} (#{qc.id}) does not have a corresponding DisplayField."
        missing_display_field_count += 1
        survey_versions << qc.survey_version
        surveys << qc.survey_version.try(:survey)

        display_field = question_helper.recreate_display_field
        new_display_fields << display_field
        rule = question_helper.recreate_default_rule
        rules << rule
      end
    end

    logger.info "Created #{new_display_fields.compact!.count} new display fields."
    logger.info "Created #{rules.compact!.count} new rules."

    logger.info "Survey IDs:"
    logger.info surveys.compact.uniq.map(&:id).inspect
    logger.info "#{surveys.compact.uniq.count} Surveys affected."

    logger.info "SurveyVersion IDs:"
    logger.info survey_versions.compact.uniq.map(&:id).inspect
    logger.info "#{survey_versions.compact.uniq.count} SurveyVersions affected."

    logger.info "Recreating default DisplayFieldValues."
    new_display_fields.each_with_index { |df, i|
      logger.info "(#{i+1}/#{new_display_fields.size}) generating DisplayField Values for (#{df.id})..."
      df.populate_default_values!
    }
    logger.info "Rerun all newly created rules on the existing responses."
    rules.compact.each_with_index { |rule, i|
      logger.info "(#{i+1}/#{rules.count}) applying rule for (#{rule.id})"
      rule.apply_me_all
    }
  }

end

class QuestionHelper

  attr_accessor :display_field, :rule, :question_content, :logger

  delegate :survey_version, to: :question_content

  def initialize(question_content, logger=nil)
    @logger = logger
    @question_content = question_content
  end

  def has_display_field?
    # Matrix question parent questions do not have a display field.
    return true if question_content.questionable_type == "MatrixQuestion"

    survey_version.display_fields.any? {|df| df.name == name}
  rescue => e
    logger.info "Caught exception #{e}"
    false
  end

  def missing_display_field?
    !has_display_field?
  end

  def recreate_display_field
    return if survey_version.nil?
    @display_field = DisplayFieldText.create!(
      :name => name,
      :required => false,
      :searchable => false,
      :default_value => "",
      :display_order => (survey_version.display_fields.maximum(:display_order) + 1),
      :survey_version_id => survey_version.id,
      :editable => false
    )
  end

  def recreate_default_rule
    return if display_field.nil? || survey_version.nil?

    @rule = survey_version.rules.create! :name => name,
      :rule_order => (survey_version.rules.count + 1),
      :execution_trigger_ids => [ExecutionTrigger::ADD],
      :action_type => 'db',
      :criteria_attributes => [
        {:source_id => question_content.id, :source_type => "QuestionContent", :conditional_id => 10, :value => ""}
      ],
      :actions_attributes => [
        {:display_field_id => display_field.id, :value_type => "Response", :value => question_content.id.to_s}
      ]
  end

  def name
    @name ||= if question_content.questionable_type == "ChoiceQuestion" && question_content.questionable.matrix_question
      @name = "#{question_content.questionable.matrix_question.statement}: #{question_content.statement}"
    else
      @name = question_content.statement
    end
  end

end
