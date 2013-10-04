class AddCountsUpdatedAtToSurveyVersions < ActiveRecord::Migration
  def self.up
    add_column :survey_versions, :counts_updated_at, :datetime
  end

  def self.down
    remove_column :survey_versions, :counts_updated_at
  end
end
