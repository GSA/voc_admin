class AddOrderToDashboardElements < ActiveRecord::Migration
  def self.up
    add_column :dashboard_elements, :sort_order, :integer
  end

  def self.down
    remove_column :dashboard_elements, :sort_order
  end
end
