class AddEditableToDisplayField < ActiveRecord::Migration
  def self.up
  	add_column :display_fields, :editable, :boolean, :default => 1

    # Mark all existing display fields as non-editable
    DisplayField.update_all ["display_fields.editable = ?", false]
  end

  def self.down
  	remove_column :display_fields, :editable
  end
end
