class RemoveVisitsFromSurveyVersions < ActiveRecord::Migration
  def self.up
    remove_column :survey_versions, :visits
  end

  def self.down
    add_column :survey_versions, :visits, :integer, :default => 0
  end
end
