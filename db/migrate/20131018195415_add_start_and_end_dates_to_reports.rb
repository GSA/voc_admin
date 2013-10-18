class AddStartAndEndDatesToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :start_date, :date
    add_column :reports, :end_date, :date
  end

  def self.down
    remove_column :reports, :start_date
    remove_column :reports, :end_date
  end
end
