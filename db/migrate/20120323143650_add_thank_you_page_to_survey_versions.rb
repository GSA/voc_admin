class AddThankYouPageToSurveyVersions < ActiveRecord::Migration
  def self.up
    add_column :survey_versions, :thank_you_page, :text
  end

  def self.down
    remove_column :survey_versions, :thank_you_page
  end
end
