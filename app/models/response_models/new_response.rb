# == Schema Information
# Schema version: 20110428194741
#
# Table name: new_responses
#
#  id                 :integer(4)      not null, primary key
#  created_at         :datetime
#  updated_at         :datetime
#  survey_response_id :integer(4)
#

class NewResponse < ActiveRecord::Base

  belongs_to :survey_response

  scope :next_response, joins(:survey_response).where('survey_responses.status_id = ?', Status::NEW).order('new_responses.created_at ASC').limit(1)

end
