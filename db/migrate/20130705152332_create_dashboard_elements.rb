class CreateDashboardElements < ActiveRecord::Migration
  def self.up
    create_table :dashboard_elements do |t|
      t.string :type

      t.references :dashboard

      t.timestamps
    end
  end

  def self.down
    drop_table :dashboard_elements
  end
end
