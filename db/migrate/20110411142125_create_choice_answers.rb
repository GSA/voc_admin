class CreateChoiceAnswers < ActiveRecord::Migration
  def self.up
    create_table :choice_answers do |t|
      t.string :answer
      t.integer :choice_question_id
      t.integer :answer_order
      t.integer :next_page_id

      t.timestamps
    end
  end

  def self.down
    drop_table :choice_answers
  end
end
