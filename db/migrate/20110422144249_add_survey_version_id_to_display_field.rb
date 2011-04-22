class AddSurveyVersionIdToDisplayField < ActiveRecord::Migration
  def self.up
    add_column :display_fields, :survey_version_id, :integer
  end

  def self.down
    remove_column :display_fields, :survey_version_id
  end
end
