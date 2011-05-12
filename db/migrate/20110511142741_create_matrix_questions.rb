class CreateMatrixQuestions < ActiveRecord::Migration
  def self.up
    create_table :matrix_questions do |t|
      t.text :statement

      t.timestamps
    end
  end

  def self.down
    drop_table :matrix_questions
  end
end
