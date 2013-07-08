class CreateReportElements < ActiveRecord::Migration
  def self.up
    create_table :report_elements do |t|
      t.string :type

      t.references :report
      t.references :choice_question
      t.references :text_question
      t.references :matrix_question

      t.timestamps
    end
  end

  def self.down
    drop_table :report_elements
  end
end
