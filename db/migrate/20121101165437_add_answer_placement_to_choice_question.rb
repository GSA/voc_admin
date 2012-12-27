class AddAnswerPlacementToChoiceQuestion < ActiveRecord::Migration
  def self.up
    add_column :choice_questions, :answer_placement, :boolean
  end

  def self.down
    remove_column :choice_questions, :answer_placement
  end
end
