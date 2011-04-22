class UpdateDfv2 < ActiveRecord::Migration
  def self.up
    remove_column :display_field_values, :type
  end

  def self.down
    add_column :display_field_values, :type, :string, :null=>false
  end
end
