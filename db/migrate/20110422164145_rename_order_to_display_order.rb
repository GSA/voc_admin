class RenameOrderToDisplayOrder < ActiveRecord::Migration
  def self.up
    rename_column :display_fields, :order, :display_order
  end

  def self.down
    rename_column :display_fields, :display_order, :order
  end
end
