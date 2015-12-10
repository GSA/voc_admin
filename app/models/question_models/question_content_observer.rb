# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# QuestionContentObserver is responsible for 1.) initially creating Rules, and
# 2.) creating and maintaining DisplayFields, when the QuestionContent object is modified.
class QuestionContentObserver < ActiveRecord::Observer
  observe :question_content

  # Creates a DisplayField and a Rule for each TextQuestion or ChoiceQuestion
  # (incl. those contained within a MatrixQuestion.)
  #
  # @param [QuestionContent] question_content the QuestionContent being observed
  def after_create(question_content)
    return if question_content.matrix_question? || question_content.skip_observer

    name = question_content.statement
    if question_content.questionable_type == "ChoiceQuestion" &&
        question_content.questionable.matrix_question
      name = "#{question_content.matrix_statement}: " + name
    end

    begin
      # DB-backed display field auto creation
      display_field = create_default_display_field(question_content, name)
      raise ActiveRecord::Rollback unless display_field.present?

      default_rule = create_default_rule(question_content, display_field, name)
      raise ActiveRecord::Rollback unless default_rule.present?

    rescue
      question_content.errors.add(:statement, "must be unique")
      raise ActiveRecord::Rollback
    end
  end

  # Updates the names of associated display fields when QuestionContent.statement changes
  #
  # @param [QuestionContent] question_content the QuestionContent being observed
  def after_update(question_content)
    return if question_content.skip_observer
    return unless question_content.statement_changed?

    if question_content.questionable_type == "MatrixQuestion"
      children = question_content.questionable.choice_questions.includes(:question_content)
      children.each do |question|
        old_name = "#{question_content.statement_was}: #{question.question_content.statement}"
        new_name = "#{question_content.statement}: #{question.question_content.statement}"

        display_field = question_content.survey_version.display_fields.find_by_name(old_name)
        display_field.update_attributes(:name => new_name)
      end
    elsif question_content.questionable_type == "ChoiceQuestion" && question_content.questionable.matrix_question.present?
      display_field = question_content.survey_version.display_fields.find_by_name("#{question_content.questionable.matrix_question.question_content.statement}: #{question_content.statement_was}")
      display_field.update_attributes(:name => "#{question_content.questionable.matrix_question.question_content.statement}: #{question_content.statement}")
    else
      display_field = question_content.survey_version.display_fields.find_by_name(question_content.statement_was)
      display_field.update_attributes(:name => question_content.statement)
    end
  end

  private
  # Will raise a validation exception if not created
  def create_default_display_field(question_content, name)
    display_field = DisplayFieldText.create!(
      :name => name,
      :required => false,
      :searchable => false,
      :default_value => "",
      :display_order => (question_content.survey_version.display_fields.count + 1),
      :survey_version_id => question_content.survey_version.id,
      :editable => false
    )
    question_content.display_fields << display_field
    display_field
  end

  # Will raise a validation exception if there is an error creating the rule
  def create_default_rule(question_content, display_field, name)
    return if display_field.nil?

    question_content.survey_version.rules.create! :name => name, :rule_order => (question_content.survey_version.rules.count + 1),
      :execution_trigger_ids => [ExecutionTrigger::ADD],
      :action_type => 'db',
      :criteria_attributes => [
        {:source_id => question_content.id, :source_type => "QuestionContent", :conditional_id => 10, :value => ""}
      ],
      :actions_attributes => [
        {:display_field_id => display_field.id, :value_type => "Response", :value => question_content.id.to_s}
      ]
  end
end
