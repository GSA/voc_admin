class AddOptionsHashToDashboardElements < ActiveRecord::Migration
  def self.up
    add_column :dashboard_elements, :options, :string
  end

  def self.down
    remove_column :dashboard_elements, :options
  end
end
