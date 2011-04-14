class CreateSurveyElements < ActiveRecord::Migration
  def self.up
    create_table :survey_elements do |t|
      t.integer :page_id
      t.integer :element_order
      t.integer :assetable_id
      t.string :assetable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_elements
  end
end
