class AddCreatedByToSurveyVersion < ActiveRecord::Migration
  def self.up
    add_column :survey_versions, :created_by_id, :integer
  end

  def self.down
    remove_column :survey_versions, :created_by_id
  end
end
