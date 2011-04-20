class CreateDisplayFieldValues < ActiveRecord::Migration
  def self.up
    create_table :display_field_values do |t|
      t.integer :display_field_id, :null=>false
      t.integer :response_id, :null=>false
      t.string  :value
      t.string  :type
      t.timestamps
    end
  end

  def self.down
    drop_table :display_field_values
  end
end
