class UpdateResponses < ActiveRecord::Migration
  def self.up
    add_column :raw_responses, :worker_name, :string
    add_column :processed_responses, :worker_name, :string
    change_column :raw_responses, :status_id, :integer, :default=> 1, :null=>false
    add_column :processed_responses, :status_id, :integer, :default=> 1, :null=>false
  end

  def self.down
    change_column :raw_responses, :status_id, :integer
    remove_column :processed_responses, :status_id, :integer
    remove_column :raw_responses, :worker_name
    remove_column :processed_responses, :worker_name
  end
end
