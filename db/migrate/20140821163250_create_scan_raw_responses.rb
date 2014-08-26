class CreateScanRawResponses < ActiveRecord::Migration
  def self.up
    create_table :scan_raw_responses do |t|
      t.integer :raw_response_id
      t.string :client_id
      t.text :answer
      t.integer :question_content_id
      t.integer :status_id
      t.string :worker_name
      t.integer :survey_response_id

      t.timestamps
    end
  end

  def self.down
    drop_table :scan_raw_responses
  end
end
