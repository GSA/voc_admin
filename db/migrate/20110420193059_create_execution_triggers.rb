class CreateExecutionTriggers < ActiveRecord::Migration
  def self.up
    create_table :execution_triggers do |t|
      t.string :name, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :execution_triggers
  end
end
