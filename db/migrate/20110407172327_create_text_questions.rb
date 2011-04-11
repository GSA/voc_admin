class CreateTextQuestions < ActiveRecord::Migration
  def self.up
    create_table :text_questions do |t|
      t.string :answer_type

      t.timestamps
    end
  end

  def self.down
    drop_table :text_questions
  end
end
