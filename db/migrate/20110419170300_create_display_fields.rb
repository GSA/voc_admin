class CreateDisplayFields < ActiveRecord::Migration
  def self.up
    create_table :display_fields do |t|
      t.string :name, :null=>false
      t.string :field_type, :null=>false
      t.boolean :required, :default=>false
      t.boolean :searchable, :default => false
      t.string :default_value
      t.timestamps
    end
  end

  def self.down
    drop_table :display_fields
  end
end
