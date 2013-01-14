class QuestionContent < ActiveRecord::Base
  belongs_to :questionable, :polymorphic => true, :dependent => :destroy
  has_many :criteria, :as => :source
  has_many :raw_responses, :foreign_key => "question_content_id" # likely currently unused. had a typo

  validates :statement, :presence => true

  attr_accessible :statement, :question_number, :flow_control, :required, :questionable, :matrix_statement, :skip_observer
  attr_accessor :matrix_statement, :skip_observer

  delegate :check_condition, :get_true_value, :to => :questionable
  delegate :survey_version, :to => :questionable, :allow_nil => true
  delegate :matrix_question, :to => :questionable, :allow_nil => true

  before_save :chomp_statement

  def get_display_field_header
    self.statement
  end

  def matrix_question?
    self.questionable_type == "MatrixQuestion"
  end

  def find_my_clone_for(clone_survey_version)
    questions = clone_survey_version.questions
    clone_survey_version.matrix_questions.each do |mq|
      questions.concat(mq.choice_questions.all)
    end
    new_question = questions.detect {|q| q.clone_of_id == self.questionable.id}
    new_question.try(:question_content)
  end

  private
  def chomp_statement
    self.statement.chomp!
  end
end

# == Schema Information
#
# Table name: question_contents
#
#  id                :integer(4)      not null, primary key
#  statement         :string(255)
#  questionable_type :string(255)
#  questionable_id   :integer(4)
#  flow_control      :boolean(1)
#  required          :boolean(1)      default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#

