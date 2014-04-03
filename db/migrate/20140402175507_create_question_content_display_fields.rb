class CreateQuestionContentDisplayFields < ActiveRecord::Migration
  def self.up
    create_table :question_content_display_fields do |t|
      t.integer :question_content_id
      t.integer :display_field_id

      t.timestamps
    end
  end

  def self.down
    drop_table :question_content_display_fields
  end
end
