class AddAnswerPlacementToChoiceQuestion < ActiveRecord::Migration
  def self.up
    add_column :choice_questions, :answer_placement, :bool
  end

  def self.down
    remove_column :choice_questions, :answer_placement
  end
end
