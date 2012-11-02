class AddSiteIdToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :site_id, :integer
    add_index :surveys, :site_id
  end

  def self.down
    remove_column :surveys, :site_id
  end
end
