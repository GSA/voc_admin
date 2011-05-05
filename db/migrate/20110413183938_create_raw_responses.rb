class CreateRawResponses < ActiveRecord::Migration
  def self.up
    create_table :raw_responses do |t|
      t.integer :survey_version_id
      t.string :client_id
      t.text :answer
      t.integer :question_content_id
      t.integer :status_id

      t.timestamps
    end
  end

  def self.down
    drop_table :raw_responses
  end
end
