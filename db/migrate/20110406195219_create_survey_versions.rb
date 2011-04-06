class CreateSurveyVersions < ActiveRecord::Migration
  def self.up
    create_table :survey_versions do |t|
      t.integer :survey_id
      t.integer :major
      t.integer :minor
      t.boolean :published
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_versions
  end
end
