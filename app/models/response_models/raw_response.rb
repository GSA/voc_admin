# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# RawResponse represents a single user answer to a single question. It is,
# outside of the processing status, the immutable record of what one user
# has entered for one question on a SurveyVersion.  From this entity,
# DisplayFieldValue objects are instantiated and values populated.
class RawResponse < ActiveRecord::Base
  belongs_to :question_content
  belongs_to :status
  belongs_to :survey_response

  validates :client_id, :presence => true, :uniqueness => {:scope => :question_content_id}
  validates :question_content, :presence => true
  validates :survey_response, :presence => true
  validates :status_id, :presence => true
  validates :answer, :presence => true

  default_scope -> { order('created_at DESC') }
  scope :status_new, -> { where(:status_id => Status::NEW) }
  scope :status_processing, -> { where(:status_id => Status::PROCESSING) }
  scope :status_error, -> { where(:status_id => Status::ERROR) }

  scope :not_archived, -> { joins(:survey_response).where('survey_responses.archived = 0') }

  # Allows Question types to handle the parsing of answers.
  #
  # @return [String] a string representation of the Question type's answered value
  def get_true_value
    question_content.get_true_value(self.answer)
  end

  # A simple setter used to ensure Arrays are stored correctly.
  #
  # @param [Number, String, Array] value the value to be set
  def answer=(value)
    if value.class == Array
      write_attribute(:answer, value.join(','))
    else
      write_attribute(:answer, value)
    end
  end

end

# == Schema Information
#
# Table name: raw_responses
#
#  id                  :integer          not null, primary key
#  client_id           :string(255)
#  answer              :text
#  question_content_id :integer
#  status_id           :integer          default(1), not null
#  created_at          :datetime
#  updated_at          :datetime
#  worker_name         :string(255)
#  survey_response_id  :integer          not null
#

