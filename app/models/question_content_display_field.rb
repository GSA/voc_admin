class QuestionContentDisplayField < ActiveRecord::Base
  belongs_to :question_content
  belongs_to :display_field
end

# == Schema Information
#
# Table name: question_content_display_fields
#
#  id                  :integer          not null, primary key
#  question_content_id :integer
#  display_field_id    :integer
#  created_at          :datetime
#  updated_at          :datetime
#

