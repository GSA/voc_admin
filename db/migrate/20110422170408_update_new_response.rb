class UpdateNewResponse < ActiveRecord::Migration
  def self.up
    remove_column :new_responses, :client_id
    add_column :new_responses, :survey_response_id, :integer, :mull=>false
  end

  def self.down
    add_column :new_responses, :client_id, :string, :null=>false
    remove_column :new_responses, :survey_response_id
  end
end
