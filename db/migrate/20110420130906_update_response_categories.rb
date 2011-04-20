class UpdateResponseCategories < ActiveRecord::Migration
  def self.up
    add_column :response_categories, :display_field_value_id, :integer, :null=>false
    add_column :response_categories, :survey_version_id, :integer, :null=>false
  end

  def self.down
    remove_column :response_categories, :display_field_value_id
    remove_column :response_categories, :survey_version_id
  end
end
