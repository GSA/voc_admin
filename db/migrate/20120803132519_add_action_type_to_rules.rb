class AddActionTypeToRules < ActiveRecord::Migration
  def self.up
    add_column :rules, :action_type, :string, :default => 'db'

    # Mark all existing rules as db action types
    Rule.update_all ["action_type = ?", 'db']
  end

  def self.down
    remove_column :rules, :action_type
  end
end
