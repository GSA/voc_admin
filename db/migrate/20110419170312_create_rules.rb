class CreateRules < ActiveRecord::Migration
  def self.up
    create_table :rules do |t|
      t.string  :name, :null=>false
      t.string  :type, :null=>false
      t.integer :display_field_id, :null=>false
      t.string  :regex        #needed to match a text question
      t.integer :question_id  #needed to match a text question
      t.integer :answer_id    #needed to match a choice question
      t.integer :category_id  #needed to match a choice question
      t.timestamps
    end
  end

  def self.down
    drop_table :rules
  end
end
