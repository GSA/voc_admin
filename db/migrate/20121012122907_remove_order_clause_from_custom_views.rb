class RemoveOrderClauseFromCustomViews < ActiveRecord::Migration
  def self.up
  	remove_column :custom_views, :order_clause
  end

  def self.down
  	add_column :custom_views, :order_clause, :text
  end
end
