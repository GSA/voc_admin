class AddCloneOfIds < ActiveRecord::Migration
  def self.up
    add_column :rules, :clone_of_id, :integer
    add_column :criteria, :clone_of_id, :integer
    add_column :actions, :clone_of_id, :integer
    add_column :display_fields, :clone_of_id, :integer
    add_column :pages, :clone_of_id, :integer
    add_column :text_questions, :clone_of_id, :integer
    add_column :choice_questions, :clone_of_id, :integer
    add_column :choice_answers, :clone_of_id, :integer
    add_column :matrix_questions, :clone_of_id, :integer
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
