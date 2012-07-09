class AddAnswerSizeToTextQuestions < ActiveRecord::Migration
  def self.up
    add_column :text_questions, :answer_size, :integer
  end

  def self.down
    remove_column :text_questions, :answer_size
  end
end
