class AddChoicesToDisplayFields < ActiveRecord::Migration
  def self.up
  	add_column :display_fields, :choices, :string
  end

  def self.down
  	remove_column :display_fields, :choices
  end
end
