class UpdateRules < ActiveRecord::Migration
  def self.up
    remove_column :rules, :display_field_id
    remove_column :rules, :regex
    remove_column :rules,:question_id
    remove_column :rules,:answer_id
    remove_column :rules,:category_id
    remove_column :rules,:type
    
    add_column :rules, :survey_version_id, :integer, :null=>false
    
  end

  def self.down
    add_column :rules, :display_field_id, :integer
    add_column :rules, :regex, :string
    add_column :rules,:question_id, :integer
    add_column :rules,:answer_id, :integer
    add_column :rules,:category_id, :integer
    add_column :rules, :type, :string
    remove_column :rules, :survey_version_id
  end
end
