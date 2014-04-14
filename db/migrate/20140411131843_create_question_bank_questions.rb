class CreateQuestionBankQuestions < ActiveRecord::Migration
  def self.up
    create_table :question_bank_questions do |t|
      t.integer :question_bank_id
      t.integer :bankable_id
      t.string :bankable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :question_bank_questions
  end
end
