class CreateQuestionContents < ActiveRecord::Migration
  def self.up
    create_table :question_contents do |t|
      t.string :name
      t.string :statement
      t.integer :number
      t.string :questionable_type
      t.integer :questionable_id
      t.integer :display_id
      t.boolean :flow_control
      t.boolean :required

      t.timestamps
    end
  end

  def self.down
    drop_table :question_contents
  end
end
