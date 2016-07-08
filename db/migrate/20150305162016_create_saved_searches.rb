class CreateSavedSearches < ActiveRecord::Migration
  def self.up
    create_table :saved_searches do |t|
      t.string :name
      t.integer :survey_version_id
      t.text :search_params

      t.timestamps
    end
  end

  def self.down
    drop_table :saved_searches
  end
end
