class AddStatusIdToSr < ActiveRecord::Migration
  def self.up
    add_column :survey_responses, :status_id, :integer, :null=>false, :default=>1
    add_column :survey_responses, :last_processed, :date
  end

  def self.down
    remove_column :survey_responses, :status_id
    remove_column :survey_responses, :last_processed
  end
end
