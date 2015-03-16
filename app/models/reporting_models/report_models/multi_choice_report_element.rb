class MultiChoiceReportElement < ChoiceReportElement

end

# == Schema Information
#
# Table name: report_elements
#
#  id                 :integer          not null, primary key
#  type               :string(255)
#  report_id          :integer
#  choice_question_id :integer
#  text_question_id   :integer
#  matrix_question_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#

