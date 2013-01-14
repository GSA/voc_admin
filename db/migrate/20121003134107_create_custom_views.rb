class CreateCustomViews < ActiveRecord::Migration
  def self.up
    create_table :custom_views do |t|
      t.integer :survey_version_id
      t.string :name
      t.text :order_clause
      t.boolean :default

      t.timestamps
    end

    add_index :custom_views, :survey_version_id
  end

  def self.down
    drop_table :custom_views
  end
end
