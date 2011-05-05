class CreateProcessedResponses < ActiveRecord::Migration
  def self.up
    create_table :processed_responses do |t|
      t.integer :survey_version_id, :null=>false
      t.string :client_id, :null=>false
      t.text :answer
      t.integer :question_content_id, :null=>false
      t.timestamps
    end
        
    create_table :categories do |t|
      t.string :name
      t.timestamps
    end
        
    create_table :response_categories do |t|
      t.integer :category_id, :null=>false
      t.integer :process_response_id, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :response_categories
    drop_table :categories
    drop_table :processed_responses
  end
end
