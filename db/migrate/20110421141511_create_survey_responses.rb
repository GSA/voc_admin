class CreateSurveyResponses < ActiveRecord::Migration
  def self.up
    create_table :survey_responses do |t|
      t.string :client_id
      t.integer :survey_version_id

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_responses
  end
end
