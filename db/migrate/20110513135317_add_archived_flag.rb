class AddArchivedFlag < ActiveRecord::Migration
  def self.up
    add_column :survey_versions, :archived, :boolean, :default=>false
    add_column :surveys, :archived, :boolean, :default=>false
  end

  def self.down
    remove_column :survey_versions, :archived
    remove_column :surveys, :archived
  end
end
