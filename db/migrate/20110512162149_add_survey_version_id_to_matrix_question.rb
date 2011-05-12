class AddSurveyVersionIdToMatrixQuestion < ActiveRecord::Migration
  def self.up
    add_column :matrix_questions, :survey_version_id, :integer
  end

  def self.down
    remove_column :matrix_questions, :survey_version_id
  end
end
