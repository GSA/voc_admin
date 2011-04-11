class CreateChoiceQuestions < ActiveRecord::Migration
  def self.up
    create_table :choice_questions do |t|
      t.boolean :multiselect
      t.string :answer_type

      t.timestamps
    end
  end

  def self.down
    drop_table :choice_questions
  end
end
