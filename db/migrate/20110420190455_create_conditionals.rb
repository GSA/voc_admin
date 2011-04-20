class CreateConditionals < ActiveRecord::Migration
  def self.up
    create_table :conditionals do |t|
      t.string :name, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :conditionals
  end
end
