class CreateSurveyVisitCounts < ActiveRecord::Migration
  def self.up
    create_table :survey_visit_counts do |t|
      t.references :survey_version
      t.date :visit_date
      t.integer :visits, :default => 0
      t.timestamps
    end

    add_index :survey_visit_counts, :survey_version_id
    add_index :survey_visit_counts, [:survey_version_id, :visit_date], :unique => true
  end

  def self.down
    drop_table :survey_visit_counts
  end
end
