class AddSelectionLegendsToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :radio_selection_legend, :string
    add_column :surveys, :checkbox_selection_legend, :string
  end
end
