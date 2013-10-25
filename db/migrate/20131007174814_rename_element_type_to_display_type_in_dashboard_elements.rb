class RenameElementTypeToDisplayTypeInDashboardElements < ActiveRecord::Migration
  def self.up
    rename_column :dashboard_elements, :element_type, :display_type
    DashboardElement.all.each do |de|
      if de.display_type == "count_per_answer_option"
        begin
          if de.reporter.nil? || de.reporter.allows_multiple_selection
            de.update_attribute :display_type, "bar"
          else
            de.update_attribute :display_type, "pie"
          end
        rescue
          de.destroy
        end
      end
    end
  end

  def self.down
    rename_column :dashboard_elements, :display_type, :element_type
    DashboardElement.all.each do |de|
      unless de.element_type == "word_cloud"
        de.update_attribute :element_type, "count_per_answer_option"
      end
    end
  end
end
