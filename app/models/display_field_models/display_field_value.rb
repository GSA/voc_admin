# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# A DisplayFieldValue represents the intersection between a SurveyResponse and a DisplayField.
# It is a single data point within a SurveyResponse and can represent a respondent's answer to a question
# or admin-defined data.
class DisplayFieldValue < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper

  belongs_to :display_field
  belongs_to :survey_response

  VALUE_DELIMITER = '{%delim%}'

  # Arel named scopes
  scope :for_display_field, ->(df_id) { where(:display_field_id => df_id) }
  scope :value_eq,          ->(val) { arel_table[:value].eq(val) }
  scope :value_not_eq,      ->(val) { arel_table[:value].not_eq(val) }
  scope :value_matches,     ->(val) { arel_table[:value].matches(val) }
  scope :value_not_matches, ->(val) { arel_table[:value].not_matches(val) }

  # Search the DisplayFieldValues
  #
  # @param [Hash] criteria should be of the format: { "0" => { 'include_exclude' => [0/1], 'condition' => [equals, contains...], '} }
  # @return [Array<DisplayFieldValue>] any matching DisplayFieldValues
  def self.search(criteria = {})
    search_scope = nil
    criteria.each do |k, criteria_fields|
      search_scope = search_scope | generate_scope(criteria_fields) if criteria_fields.delete('clause_join') == 'OR'
      search_scope = search_scope & generate_scope(criteria_fields) if criteria_fields.delete('clause_join') == 'AND'
    end
  end

  # Used to store an array of data within the value field, e.g. selected checkbox values.
  # Joins the array using a delimiter very unlikely to be entered by a respondent.
  #
  # @param [Array<String>] arg the Array to store
  # @return [String] the serialized field value
  def value_array=(arg)
  	self.value = arg.join(VALUE_DELIMITER)
  end

  def display_value
    sanitized_value = sanitize(value)
    sanitized_value ? sanitized_value.gsub("\n", VALUE_DELIMITER).gsub(VALUE_DELIMITER,  "<br/>") : ""
  end

  def truncated_display_value
    truncate(display_value, :length => 200)
  end

  private
  def generate_scope(criteria)

  end

end

# == Schema Information
#
# Table name: display_field_values
#
#  id                 :integer          not null, primary key
#  display_field_id   :integer          not null
#  survey_response_id :integer          not null
#  value              :text
#  created_at         :datetime
#  updated_at         :datetime
#

