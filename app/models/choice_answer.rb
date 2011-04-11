class ChoiceAnswer < ActiveRecord::Base
  belongs_to :choice_question
  belongs_to :page, :foreign_key => :next_page_id

end
