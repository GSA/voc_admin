class AddSurveyElementReferenceToDashboardElements < ActiveRecord::Migration
  def self.up
    add_column :dashboard_elements, :survey_element_id, :integer
    add_index :dashboard_elements, :survey_element_id
  end

  def self.down
  	remove_index :dashboard_elements, :survey_element_id
  	remove_column :dashboard_elements, :survey_element_id
  end
end
