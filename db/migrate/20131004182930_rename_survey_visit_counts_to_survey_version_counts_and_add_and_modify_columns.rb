class RenameSurveyVisitCountsToSurveyVersionCountsAndAddAndModifyColumns < ActiveRecord::Migration
  def self.up
    remove_column :survey_versions, :questions_skipped
    remove_column :survey_versions, :questions_asked

    rename_table :survey_visit_counts, :survey_version_counts
    rename_column :survey_version_counts, :visit_date, :count_date
    add_column :survey_version_counts, :questions_skipped, :integer, :default => 0
    add_column :survey_version_counts, :questions_asked, :integer, :default => 0
  end

  def self.down
    add_column :survey_versions, :questions_skipped, :integer, :default => 0
    add_column :survey_versions, :questions_asked, :integer, :default => 0

    rename_table :survey_version_counts, :survey_visit_counts
    rename_column :survey_visit_counts, :count_date, :visit_date
    remove_column :survey_visit_counts, :questions_skipped
    remove_column :survey_visit_counts, :questions_asked
  end
end
