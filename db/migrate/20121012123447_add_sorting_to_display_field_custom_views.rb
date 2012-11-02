class AddSortingToDisplayFieldCustomViews < ActiveRecord::Migration
  def self.up
    add_column :display_field_custom_views, :sort_order, :integer
    add_column :display_field_custom_views, :sort_direction, :string
  end

  def self.down
    remove_column :display_field_custom_views, :sort_direction
    remove_column :display_field_custom_views, :sort_order
  end
end
