class AddEditableToDisplayField < ActiveRecord::Migration
  def self.up
  	add_column :display_fields, :editable, :boolean, :default => 1
  end

  def self.down
  	remove_column :display_fields, :editable
  end
end
