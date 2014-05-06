class AddStartPageTitleToSurvey < ActiveRecord::Migration
  def self.up
    add_column :surveys, :start_page_title, :string
  end

  def self.down
    remove_column :surveys, :start_page_title
  end
end
