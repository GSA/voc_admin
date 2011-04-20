class CreateCriteria < ActiveRecord::Migration
  def self.up
    create_table :criteria do |t|
      t.integer :rule_id, :null=>false
      t.integer :source, :null=>false
      t.integer :conditional_id, :null=>false
      t.string  :value
      t.timestamps
    end
  end

  def self.down
    drop_table :criteria
  end
end
