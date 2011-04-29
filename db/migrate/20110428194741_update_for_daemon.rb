class UpdateForDaemon < ActiveRecord::Migration
  def self.up
    remove_column :new_responses, :status_id
    add_column :survey_responses, :worker_name, :string
    change_column :survey_responses, :last_processed, :datetime
  end

  def self.down
    remove_column :survey_responses, :worker_name
    add_column :new_responses, :status_id, :integer
    change_column :survey_responses, :last_processed, :date
  end
end
