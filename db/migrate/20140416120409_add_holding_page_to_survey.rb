class AddHoldingPageToSurvey < ActiveRecord::Migration
  def self.up
    add_column :surveys, :holding_page, :text
  end

  def self.down
    remove_column :surveys, :holding_page
  end
end
