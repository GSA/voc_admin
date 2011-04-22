class MakeSourcePoly < ActiveRecord::Migration
  def self.up
    add_column :criteria, :source_type, :string, :null=>false
    rename_column :criteria, :source, :source_id
  end

  def self.down
    remove_column :criteria, :source_type
    rename_column :criteria, :source_id, :source
  end
end
