class AddSurveyVersionIdToExports < ActiveRecord::Migration
  def self.up
    add_column :exports, :survey_version_id, :int
  end

  def self.down
    remove_column :exports, :survey_version_id
  end
end
