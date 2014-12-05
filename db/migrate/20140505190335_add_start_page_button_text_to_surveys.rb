class AddStartPageButtonTextToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :start_screen_button_text, :string
  end

  def self.down
    remove_column :surveys, :start_screen_button_text
  end
end
