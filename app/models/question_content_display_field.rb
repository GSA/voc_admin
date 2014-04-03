class QuestionContentDisplayField < ActiveRecord::Base
  belongs_to :question_content
  belongs_to :display_field
end
