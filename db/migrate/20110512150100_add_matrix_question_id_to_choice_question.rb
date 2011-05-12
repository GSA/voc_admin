class AddMatrixQuestionIdToChoiceQuestion < ActiveRecord::Migration
  def self.up
    add_column :choice_questions, :matrix_question_id, :integer
  end

  def self.down
    remove_column :choice_questions, :matrix_question_id
  end
end
