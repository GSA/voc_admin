class AutoNextPageToChoiceQuestions < ActiveRecord::Migration
  def self.up
    add_column :choice_questions, :auto_next_page, :boolean
  end

  def self.down
    remove_column :choice_questions, :auto_next_page
  end
end
