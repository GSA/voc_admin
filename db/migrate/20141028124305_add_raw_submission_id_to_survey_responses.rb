class AddRawSubmissionIdToSurveyResponses < ActiveRecord::Migration
  def self.up
    add_column :survey_responses, :raw_submission_id, :integer
  end

  def self.down
    remove_column :survey_responses, :raw_submission_id
  end
end
