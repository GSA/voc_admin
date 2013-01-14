class DisplayFieldValue < ActiveRecord::Base
  belongs_to :display_field
  belongs_to :survey_response

  # Arel named scopes
  scope :for_display_field, ->(df_id) { where(:display_field_id => df_id) }
  scope :value_eq, ->(val) { arel_table[:value].eq(val) }
  scope :value_not_eq, ->(val) { arel_table[:value].not_eq(val) }
  scope :value_matches, ->(val) { arel_table[:value].matches(val) }
  scope :value_not_matches, ->(val) { arel_table[:value].not_matches(val) }

  # Search the displayfield values
  # the criteria hash should be of the format: { "0" => { 'include_exclude' => [0/1], 'condition' => [equals, contains...], '} }
  def self.search(criteria = {})
    search_scope = nil
    criteria.each do |k, criteria_fields|
      search_scope = search_scope | generate_scope(criteria_fields) if criteria_fields.delete('clause_join') == 'OR'
      search_scope = search_scope & generate_scope(criteria_fields) if criteria_fields.delete('clause_join') == 'AND'
    end
  end

  def value_array=(arg)
  	self.value = arg.join('{%delim%}')
  end

  private
  def generate_scope(criteria)

  end

end

# == Schema Information
#
# Table name: display_field_values
#
#  id                 :integer(4)      not null, primary key
#  display_field_id   :integer(4)      not null
#  survey_response_id :integer(4)      not null
#  value              :text
#  created_at         :datetime
#  updated_at         :datetime
#

