class ReplaceOptionsWithElementTypeInDashboardElements < ActiveRecord::Migration
  def self.up
    rename_column :dashboard_elements, :options, :element_type
    DashboardElement.update_all(element_type: "count_per_answer_option")
  end

  def self.down
    rename_column :dashboard_elements, :element_type, :options
  end
end
