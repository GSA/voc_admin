class AddSurveyResponseIdToRawResponses < ActiveRecord::Migration
  def self.up
    add_column :raw_responses, :survey_response_id, :integer, :null => false
  end

  def self.down
    remove_column :raw_responses, :survey_response_id
  end
end
