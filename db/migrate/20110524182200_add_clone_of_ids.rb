class AddCloneOfIds < ActiveRecord::Migration
  def self.up
    add_column :rules, :clone_of_id, :integer
    add_index :rules, :clone_of_id

    add_column :criteria, :clone_of_id, :integer
    add_index :criteria, :clone_of_id

    add_column :actions, :clone_of_id, :integer
    add_index :actions, :clone_of_id

    add_column :display_fields, :clone_of_id, :integer
    add_index :display_fields, :clone_of_id

    add_column :pages, :clone_of_id, :integer
    add_index :pages, :clone_of_id

    add_column :text_questions, :clone_of_id, :integer
    add_index :text_questions, :clone_of_id

    add_column :choice_questions, :clone_of_id, :integer
    add_index :choice_questions, :clone_of_id

    add_column :choice_answers, :clone_of_id, :integer
    add_index :choice_answers, :clone_of_id

    add_column :matrix_questions, :clone_of_id, :integer
    add_index :matrix_questions, :clone_of_id
  end

  def self.down
    remove_column :rules, :clone_of_id
    remove_column :criteria, :clone_of_id
    remove_column :actions, :clone_of_id
    remove_column :display_fields, :clone_of_id
    remove_column :pages, :clone_of_id
    remove_column :text_questions, :clone_of_id
    remove_column :choice_questions, :clone_of_id
    remove_column :choice_answers, :clone_of_id
    remove_column :matrix_questions, :clone_of_id
  end
end
