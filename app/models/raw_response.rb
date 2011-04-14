# == Schema Information
# Schema version: 20110413183938
#
# Table name: raw_responses
#
#  id                :integer(4)      not null, primary key
#  survey_version_id :integer(4)
#  client_id         :string(255)
#  answer            :text
#  question_id       :integer(4)
#  status_id         :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#

class RawResponse < ActiveRecord::Base
end
