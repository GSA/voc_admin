class AddSurveyVersionIdToSurveyElement < ActiveRecord::Migration
  def self.up
    add_column :survey_elements, :survey_version_id, :integer
  end

  def self.down
    remove_column :survey_elements, :survey_version_id
  end
end
