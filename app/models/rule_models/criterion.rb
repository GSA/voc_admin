# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# A Criterion is the evaluated portion of a Rule
class Criterion < ActiveRecord::Base
  belongs_to :rule
  belongs_to :conditional
  belongs_to :source, :polymorphic=>true

  attr_accessor :source_select

  # Allows a source (TextQuestion, ChoiceQuestion, or DisplayField) to process
  # a Rule Criterion and respond with the truth value.
  #
  # @param [SurveyResponse] survey_response the response to test
  # @return [Boolean] the result of the evaluation
  def check_me(survey_response)
    if source
      source.check_condition(survey_response, self.conditional_id, self.value)
    else
      false
    end
  end

  # Sets the source DisplayField id selected from the new/edit Rule page
  # for this Criteria
  #
  # @param [String] source_string the comma-delimited id and source type
  def source_select=(source_string)
    self.source_id, self.source_type = source_string.split(',')
  end
end

# == Schema Information
#
# Table name: criteria
#
#  id             :integer          not null, primary key
#  rule_id        :integer          not null
#  source_id      :integer          not null
#  conditional_id :integer          not null
#  value          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  source_type    :string(255)      not null
#  clone_of_id    :integer
#

