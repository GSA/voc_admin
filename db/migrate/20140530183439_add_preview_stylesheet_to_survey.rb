class AddPreviewStylesheetToSurvey < ActiveRecord::Migration
  def self.up
    add_column :surveys, :invitation_preview_stylesheet, :string
    add_column :surveys, :survey_preview_stylesheet, :string
  end

  def self.down
    remove_column :surveys, :invitation_preview_stylesheet
    remove_column :surveys, :survey_preview_stylesheet
  end
end
