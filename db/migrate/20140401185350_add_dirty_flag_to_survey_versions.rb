class AddDirtyFlagToSurveyVersions < ActiveRecord::Migration
  def self.up
    add_column :survey_versions, :dirty_reports, :boolean
  end

  def self.down
    remove_column :survey_versions, :dirty_reports
  end
end
