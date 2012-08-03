class AddActionTypeToRules < ActiveRecord::Migration
  def self.up
    add_column :rules, :action_type, :string, :default => 'db'
  end

  def self.down
    remove_column :rules, :action_type
  end
end
