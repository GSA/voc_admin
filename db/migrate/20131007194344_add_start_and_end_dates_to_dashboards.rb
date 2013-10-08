class AddStartAndEndDatesToDashboards < ActiveRecord::Migration
  def self.up
    add_column :dashboards, :start_date, :date
    add_column :dashboards, :end_date, :date
  end

  def self.down
    remove_column :dashboards, :start_date
    remove_column :dashboards, :end_date
  end
end
