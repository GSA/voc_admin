# == Schema Information
# Schema version: 20110511142805
#
# Table name: raw_responses
#
#  id                  :integer(4)      not null, primary key
#  client_id           :string(255)
#  answer              :text
#  question_content_id :integer(4)
#  status_id           :integer(4)      default(1), not null
#  created_at          :datetime
#  updated_at          :datetime
#  worker_name         :string(255)
#  survey_response_id  :integer(4)      not null
#

class RawResponse < ActiveRecord::Base
  belongs_to :question_content
  belongs_to :status
  belongs_to :survey_response

  validates :client_id, :presence => true, :uniqueness => {:scope => :question_content_id}
  validates :question_content, :presence => true
  validates :survey_response, :presence => true
  validates :status_id, :presence => true
  validates :answer, :presence => true

  default_scope :order => 'created_at DESC'
  scope :status_new, where(:status_id => Status::NEW)
  scope :status_processing, where(:status_id => Status::PROCESSING)
  scope :status_error, where(:status_id => Status::ERROR)

  after_update :process_update_rules
  after_create :create_dfvs

  #allows question types to handle the parsing of answers
  def get_true_value
    question_content.get_true_value(self.answer)
  end

  def answer=(value)
    if value.class == Array
      write_attribute(:answer, value.join(','))
    else
      write_attribute(:answer, value)
    end
  end

  private
  def process_update_rules
    self.survey_response.process_me(ExecutionTrigger::UPDATE)
  end

  def create_dfvs
    DisplayField.find_all_by_survey_version_id(self.survey_response.survey_version_id).each do |df|
      dfv = DisplayFieldValue.find_or_create_by_survey_response_id_and_display_field_id(self.survey_response_id, df.id)
      dfv.update_attributes(:value => df.default_value)
    end
  end
end
