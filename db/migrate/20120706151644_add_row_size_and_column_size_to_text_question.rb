class AddRowSizeAndColumnSizeToTextQuestion < ActiveRecord::Migration
  def self.up
    add_column :text_questions, :row_size, :integer
    add_column :text_questions, :column_size, :integer
  end

  def self.down
    remove_column :text_questions, :column_size
    remove_column :text_questions, :row_size
  end
end
