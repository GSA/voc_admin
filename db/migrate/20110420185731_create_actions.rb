class CreateActions < ActiveRecord::Migration
  def self.up
    create_table :actions do |t|
      t.integer :rule_id, :null=>false
      t.integer :display_field_id, :null=>false
      t.string  :value
      t.timestamps
    end
  end

  def self.down
    drop_table :actions
  end
end
