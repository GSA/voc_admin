class AddShowNumbersToSurvey < ActiveRecord::Migration
  def self.up
    add_column :surveys, :show_numbers, :boolean, default: true
  end

  def self.down
    remove_column :surveys, :show_numbers
  end
end
