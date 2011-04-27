class AddValueTypeToAction < ActiveRecord::Migration
  def self.up
    add_column :actions, :value_type, :string
  end

  def self.down
    remove_column :actions, :value_type
  end
end
