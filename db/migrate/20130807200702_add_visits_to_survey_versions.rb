class AddVisitsToSurveyVersions < ActiveRecord::Migration
  def self.up
    add_column :survey_versions, :visits, :integer, :default => 0
  end

  def self.down
    remove_column :survey_versions, :visits
  end
end
