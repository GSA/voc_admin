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

require 'spec_helper'

describe ReportElement do
  pending "add some examples to (or delete) #{__FILE__}"
end
