# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Deprecated; used by the ResponseParser rake task to queue and process incoming
# SurveyResponses so as not to hold up the thank you page response to the client.
# ResponseParser is being phased out in preference to Delayed::Job.
class NewResponse < ActiveRecord::Base

  belongs_to :survey_response

  scope :next_response, -> {
    joins(:survey_response)
      .where('survey_responses.status_id = ?', Status::NEW)
      .order('new_responses.created_at ASC').limit(1)
  }

end

# == Schema Information
#
# Table name: new_responses
#
#  id                 :integer          not null, primary key
#  created_at         :datetime
#  updated_at         :datetime
#  survey_response_id :integer
#

