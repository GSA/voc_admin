class UpdateDfv < ActiveRecord::Migration
  def self.up
    rename_column :display_field_values, :response_id, :survey_response_id
  end

  def self.down
    rename_column :display_field_values, :survey_response_id, :response_id
  end
end
