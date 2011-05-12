class CreateMatrixQuestionChoiceQuestions < ActiveRecord::Migration
  def self.up
    create_table :matrix_question_choice_questions do |t|
      t.integer :matrix_question_id
      t.integer :choice_question_id

      t.timestamps
    end
  end

  def self.down
    drop_table :matrix_question_choice_questions
  end
end
