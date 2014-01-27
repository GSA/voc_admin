class AddSubmitButtonTextToSurvey < ActiveRecord::Migration
  def self.up
    add_column :surveys, :submit_button_text, :string
  end

  def self.down
    remove_column :surveys, :submit_button_text
  end
end