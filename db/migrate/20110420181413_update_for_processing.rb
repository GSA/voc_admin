class UpdateForProcessing < ActiveRecord::Migration
  def self.up
    add_column :display_field_values, :client_id, :string, :null=>false
    add_column :display_fields, :order, :integer, :null=>false
    remove_column :response_categories, :display_field_value_id
  end

  def self.down
    remove_column :display_field_values, :client_id
    remove_column :display_fields, :order
    add_column :response_categories, :display_field_value_id, :integer, :null=>false
  end
end
