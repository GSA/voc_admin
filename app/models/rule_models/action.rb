# == Schema Information
# Schema version: 20110524182200
#
# Table name: actions
#
#  id               :integer(4)      not null, primary key
#  rule_id          :integer(4)      not null
#  display_field_id :integer(4)      not null
#  value            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  value_type       :string(255)
#  clone_of_id      :integer(4)
#

class Action < ActiveRecord::Base
  belongs_to :rule
  belongs_to :display_field

  TEXT = "Text"
  RESPONSE = "Response"

  def perform(survey_response)
    #get target DFV
    display_field_value = DisplayFieldValue.find_or_create_by_survey_response_id_and_display_field_id(survey_response.id, self.display_field_id)
    if value_type == RESPONSE
      raw_response = RawResponse.find_by_survey_response_id_and_question_content_id(display_field_value.survey_response_id, self.value.to_i)
      display_field_value.update_attributes(:value=> (raw_response.nil? ? '' : raw_response.get_true_value))
    else
      display_field_value.update_attributes(:value =>self.value )
    end
  end
end
