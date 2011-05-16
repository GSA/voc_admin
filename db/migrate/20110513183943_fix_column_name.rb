class FixColumnName < ActiveRecord::Migration
  def self.up
    rename_column :pages, :number, :page_number
    rename_column :question_contents, :number, :question_number
  end

  def self.down
    rename_column :pages, :page_number, :number
    rename_column :question_contents, :question_number, :number
  end
end
