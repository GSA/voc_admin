class CreateNewResponses < ActiveRecord::Migration
  def self.up
    create_table :new_responses do |t|
      t.string :client_id
      t.integer :status_id

      t.timestamps
    end
  end

  def self.down
    drop_table :new_responses
  end
end
