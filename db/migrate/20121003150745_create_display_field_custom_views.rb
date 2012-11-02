class CreateDisplayFieldCustomViews < ActiveRecord::Migration
  def self.up
    create_table :display_field_custom_views do |t|
      t.integer :display_field_id
      t.integer :custom_view_id
      t.integer :display_order

      t.timestamps
    end

    add_index :display_field_custom_views, :display_field_id
    add_index :display_field_custom_views, :custom_view_id
  end

  def self.down
    drop_table :display_field_custom_views
  end
end
