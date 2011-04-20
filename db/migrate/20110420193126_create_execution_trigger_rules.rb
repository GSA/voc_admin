class CreateExecutionTriggerRules < ActiveRecord::Migration
  def self.up
    create_table :execution_trigger_rules do |t|
      t.integer :rule_id, :null=>false
      t.integer :execution_trigger_id, :null=>false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :execution_trigger_rules
  end
end
