class AddDisplayResultsToChoiceQuestions < ActiveRecord::Migration
  def self.up
    add_column :choice_questions, :display_results, :boolean
  end

  def self.down
    remove_column :choice_questions, :display_results
  end
end
