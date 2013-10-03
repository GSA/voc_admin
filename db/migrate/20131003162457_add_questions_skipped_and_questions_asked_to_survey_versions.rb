class AddQuestionsSkippedAndQuestionsAskedToSurveyVersions < ActiveRecord::Migration
  def self.up
    add_column :survey_versions, :questions_skipped, :integer, :default => 0
    add_column :survey_versions, :questions_asked, :integer, :default => 0
  end

  def self.down
    remove_column :survey_versions, :questions_skipped
    remove_column :survey_versions, :questions_asked
  end
end
