# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# QuestionContent contains fields shared between all question types (ChoiceQuestion,
# TextQuestion, MatrixQuestion) and delegates behavior where appropriate.
class QuestionContent < ActiveRecord::Base
  belongs_to :questionable, :polymorphic => true#, :dependent => :destroy
  has_many :criteria, :as => :source
  has_many :raw_responses, :foreign_key => "question_content_id" # likely currently unused. had a typo
  has_many :question_content_display_fields
  has_many :display_fields, through: :question_content_display_fields

  validates :statement, :presence => true

  attr_accessible :statement, :question_number, :flow_control, :required, :questionable, :matrix_statement, :skip_observer, :questionable_type
  attr_accessor :matrix_statement, :skip_observer

  delegate :check_condition, :get_true_value, :to => :questionable
  delegate :survey_version, :to => :questionable, :allow_nil => true
  delegate :matrix_question, :to => :questionable, :allow_nil => true

  before_save :chomp_statement

  # Questionable way to retrieve the header for the DisplayField.
  #
  # @return [String] the text for display
  def get_display_field_header
    self.statement
  end

  # Tests the QuestionContent to see if its Questionable is a MatrixQuestion.
  #
  # @return [Boolean] truth value
  def matrix_question?
    self.questionable_type == "MatrixQuestion"
  end

  # Finds the original QuestionContent on a specified SurveyVersion from which
  # the calling Question was cloned.
  #
  # @param [SurveyVersion] clone_survey_version the SurveyVersion to search within
  # @return [QuestionContent, nil] the matching QuestionContent or nil
  def find_my_clone_for(clone_survey_version)
    questions = clone_survey_version.questions
    clone_survey_version.matrix_questions.each do |mq|
      questions.concat(mq.choice_questions.all)
    end
    new_question = questions.detect {|q| q.clone_of_id == self.questionable.id}
    new_question.try(:question_content)
  end

  private

  # Trims whitespace from the end of the statement string.
  def chomp_statement
    self.statement.chomp!
  end
end

# == Schema Information
#
# Table name: question_contents
#
#  id                :integer          not null, primary key
#  statement         :string(255)
#  questionable_type :string(255)
#  questionable_id   :integer
#  flow_control      :boolean
#  required          :boolean          default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#

