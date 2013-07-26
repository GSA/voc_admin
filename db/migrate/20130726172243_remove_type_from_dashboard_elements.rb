class RemoveTypeFromDashboardElements < ActiveRecord::Migration
  def self.up
    remove_column :dashboard_elements, :type
  end

  def self.down
    add_column :dashboard_elements, :type, :string
  end
end
