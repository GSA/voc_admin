class AddDefaultToChoiceAnswer < ActiveRecord::Migration
  def self.up
    add_column(:choice_answers, :is_default, :boolean, :default=>false)
  end

  def self.down
    remove_column(:choice_answers, :is_default)
  end
end
