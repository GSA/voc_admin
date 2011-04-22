class UpdateDisplayField < ActiveRecord::Migration
  def self.up
    rename_column :display_fields, :field_type, :type
  end

  def self.down
    rename_column :display_fields, :type, :field_type
  end
end
