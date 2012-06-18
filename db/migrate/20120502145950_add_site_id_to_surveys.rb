class AddSiteIdToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :site_id, :integer
  end

  def self.down
    remove_column :surveys, :site_id
  end
end
