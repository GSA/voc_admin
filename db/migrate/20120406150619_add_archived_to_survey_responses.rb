class AddArchivedToSurveyResponses < ActiveRecord::Migration
  def self.up
    add_column :survey_responses, :archived, :boolean, :default => false
  end

  def self.down
    remove_column :survey_responses, :archived
  end
end
