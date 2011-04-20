class CreateDisplayFieldCategories < ActiveRecord::Migration
  def self.up
    create_table :display_field_categories do |t|
      t.integer :display_field_id, :null=>false
      t.integer :category_id, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :display_field_categories
  end
end
