# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# An Action is the component of the Rules system which performs the actual DisplayFieldValue update.
class Action < ActiveRecord::Base
  belongs_to :rule
  belongs_to :display_field

  validates :display_field, presence: true

  # Signifies that an Action is associated with a textual value.
  TEXT = "Text"
  # Signifies than an Action is tied to a RawResponse value.
  RESPONSE = "Response"

  # Invokes the Action for a given SurveyResponse.  Updates the appropriate DisplayFieldValue
  # with either the RawResponse's value (in case of a question response) or specific text
  # (for custom DisplayFields.)
  #
  # @param [SurveyResponse] survey_response the SurveyResponse to alter
  def perform(survey_response)
    #get target DFV
    display_field_value = DisplayFieldValue.find_or_create_by(
      survey_response_id: survey_response.id,
      display_field_id: self.display_field_id
    )
    if value_type == RESPONSE
      raw_response = RawResponse.find_by_survey_response_id_and_question_content_id(
        display_field_value.survey_response_id, self.value.to_i
      )
      display_field_value.update_attributes(
        :value=> (raw_response.nil? ? '' : raw_response.get_true_value)
      )
    else
      display_field_value.update_attributes(:value =>self.value )
    end
  end
end

# == Schema Information
#
# Table name: actions
#
#  id               :integer          not null, primary key
#  rule_id          :integer          not null
#  display_field_id :integer          not null
#  value            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  value_type       :string(255)
#  clone_of_id      :integer
#

