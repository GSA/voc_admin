class CreateQuestionBanks < ActiveRecord::Migration
  def self.up
    create_table :question_banks do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :question_banks
  end
end
