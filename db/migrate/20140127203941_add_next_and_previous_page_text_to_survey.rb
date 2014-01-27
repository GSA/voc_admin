class AddNextAndPreviousPageTextToSurvey < ActiveRecord::Migration
  def self.up
    add_column :surveys, :previous_page_text, :string
    add_column :surveys, :next_page_text, :string
  end

  def self.down
    remove_column :surveys, :previous_page_text
    remove_column :surveys, :next_page_text
  end
end
