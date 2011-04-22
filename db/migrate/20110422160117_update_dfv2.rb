class UpdateDfv2 < ActiveRecord::Migration
  def self.up
    remove_column :display_field_values, :type
    remove_column :display_field_values, :client_id
  end

  def self.down
    add_column :display_field_values, :type, :string, :null=>false
    add_column :display_field_values, :client_id, :string, :null=>false
  end
end
