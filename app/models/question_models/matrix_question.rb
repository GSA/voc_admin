# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# A MatrixQuestion is a set of ChoiceQuestions which share a single set of ChoiceAnswers.
class MatrixQuestion < ActiveRecord::Base
  has_one :survey_element, :as => :assetable, :dependent => :destroy
  has_one :question_content, :as => :questionable, :dependent => :destroy
  has_many :choice_questions, :dependent => :destroy
  belongs_to :survey_version

  has_many :question_bank_questions, as: :bankable, dependent: :destroy
  has_many :question_banks, through: :question_bank_questions

  validates :question_content, :presence => true
  validate :has_choice_questions

  attr_accessible :choice_questions_attributes, :question_content_attributes,
    :survey_element_attributes, :clone_of_id, :survey_version_id

  accepts_nested_attributes_for :question_content, :allow_destroy => false
  accepts_nested_attributes_for :choice_questions, :allow_destroy => true
  accepts_nested_attributes_for :survey_element

  before_update :remove_old_answers

  delegate :statement, :statement=, :required, :to => :question_content

  # Used in displaying the ChoiceAnswer values on the SurveyVersion show view.
  #
  # @return [Array<String>] an array of the first ChoiceQuestion's ChoiceAnswer values
  def column_headers
    return [] if self.choice_questions.empty?
    self.choice_questions.limit(1).first.choice_answers.map {|a| a.answer}
  end

  # Used for displaying ChoiceQuestion properties on the SurveyVersion show view.
  #
  # @return [ActiveRecord::Relation] an ActiveRecord::Relation of
  # the MatrixQuestion's ChoiceQuestions with proper joins included
  def rows
    self.choice_questions.includes(:question_content).includes(:choice_answers)
  end

  # Questionable type.
  def answer_type
    "matrix"
  end

  # Makes a deep copy of the MatrixQuestion (when cloning a survey)
  #
  # @param [SurveyVersion] target_sv the SurveyVersion destination for the new cloned copy
  # @return [MatrixQuestion] the cloned MatrixQuestion
  def clone_me(target_sv, target_page = nil, sv_clone = true)
    #start matrix hash
    mq_qc_attribs = self.question_content.attributes
      .except("id", "created_at", "updated_at", "questionable_id")
    cloneable_attributes = self.attributes
      .except("id", "created_at", "updated_at", "statement")
    mq_attribs = cloneable_attributes.merge(
                  :clone_of_id => (self.id),
                  :survey_version_id => (target_sv.id),
                  :question_content_attributes => mq_qc_attribs
                 )

    target_page ||= target_sv.pages.find_by_clone_of_id(self.survey_element.page_id)

    #build se hash
    se_attribs = self.survey_element.attributes
      .except("id", "created_at", "updated_at")
      .merge(
        :survey_version_id => target_sv.id,
        :page_id => (target_page.id)
      )

    #build content question hash
    choice_questions = self.choice_questions.map do |choice_question|
      qc_attribs = choice_question.question_content.attributes
        .except("id", "created_at", "updated_at", "questionable_id")
        .merge({:matrix_statement => self.statement, :skip_observer => true})

      cq_attribs = choice_question.attributes
        .except("id", "created_at", "updated_at")
      ca_attribs = choice_question.choice_answers.map do |choice_answer|
        answer_hash = choice_answer.attributes
          .except("id", "updated_at", "created_at")
          .merge(
            :clone_of_id => (choice_answer.id)
          )

        #update the next page pointer
        if answer_hash["next_page_id"]
          answer_hash["next_page_id"] = (Page.find_by_survey_version_id_and_clone_of_id( target_sv.id, new_answer.next_page_id).id)
        end
        answer_hash
      end
      cq_attribs = cq_attribs.merge(:skip_observer => true) if sv_clone # is this skip_observer even needed?
      cq_attribs = cq_attribs.merge(
        :question_content_attributes => qc_attribs,
        :choice_answers_attributes => ca_attribs,
        :clone_of_id => (choice_question.id)
      )
    end

    mq_attribs = mq_attribs.merge(
      :choice_questions_attributes => choice_questions,
      :survey_element_attributes => se_attribs
    )
    MatrixQuestion.create!(mq_attribs)
  end

  # Makes a deep copy of the MatrixQuestion (when cloning a Page)
  #
  # @param [Page] page the page to be cloned onto
  # @return [MatrixQuestion] the cloned copy
  def copy_to_page(page)
    #start matrix hash
    mq_qc_attribs = self.question_content.attributes
      .except("id", "created_at", "updated_at", "questionable_id")

    cloneable_attributes = self.attributes
      .except("id", "created_at", "updated_at", "statement")
    mq_attribs = cloneable_attributes
      .except("id", "created_at", "updated_at")
      .merge(
        :clone_of_id => nil,
        :question_content_attributes => mq_qc_attribs.merge("statement" => "#{self.question_content.statement} (copy)")
      )


    #build se hash
    se_attribs = self.survey_element.attributes
      .except("id", "created_at", "updated_at", "questionable_id")
      .merge("page_id" => page.id)

    #build content question hash
    choice_questions = self.choice_questions.map do |choice_question|
      qc_attribs = choice_question.question_content.attributes
        .except("id", "created_at", "updated_at", "questionable_id")
        .merge(
          "matrix_statement" => "#{self.question_content.statement} (copy)",
          "statement" => "#{choice_question.question_content.statement} (copy)"
        )

      cq_attribs = choice_question.attributes
        .except("id", "created_at", "updated_at")
      ca_attribs = choice_question.choice_answers.map do |choice_answer|
        answer_hash = choice_answer.attributes
          .except("id", "updated_at", "created_at")
          .merge("clone_of_id" => nil)

        #update the next page pointer
        if answer_hash["next_page_id"]
          answer_hash["next_page_id"] = nil
        end
        answer_hash
      end
      cq_attribs.merge(
        :question_content_attributes => qc_attribs,
        :choice_answers_attributes => ca_attribs,
        :clone_of_id => (choice_question.id)
      )
    end

    mq_attribs = mq_attribs.merge(:choice_questions_attributes => choice_questions, :survey_element_attributes => se_attribs)
    MatrixQuestion.create!(mq_attribs)
  end

  # Removes display field and rule for matrix sub-questions which have been marked for
  # destruction
  #
  # @param [Hash] choice_questions the ChoiceQuestion parameters for the matrix question
  def remove_deleted_sub_questions(choice_questions)
    to_be_removed = choice_questions.select {|k, value| value[:question_content_attributes][:_destroy] == "1" }
    to_be_removed.each {|key, choice_question_params| remove_sub_question_display_field_and_rules(choice_question_params)}
  end

  def reporter
    nil
  end

  def describe_me(assetable_type, element_order)
    {id: id,
     assetable_type: assetable_type,
     element_order: element_order,
     statement: question_content.statement,
     required: question_content.required,
     survey_version_id: survey_version_id,
     clone_of_id: clone_of_id,
     choice_questions: choice_questions.map {|cq| cq.describe_me("ChoiceQuestion", nil)}
     }.reject {|k, v| v.blank? }
  end

  private
  # Removes the default Rule and DisplayField mappings for a given
  # MatrixQuestion and a specific ChoiceQuestion.
  #
  # @param [Hash] choice_question_params the ChoiceQuestion parameters to remove
  def remove_sub_question_display_field_and_rules(choice_question_params)
    matrix_statement = question_content.statement_changed? ? question_content.statement_was : question_content.statement

    name = "#{matrix_statement}: #{choice_question_params[:question_content_attributes][:statement]}"

    rule = survey_version.rules.find_by_name(name)
    rule.destroy if rule.present?

    df = survey_version.display_fields.find_by_name(name)
    df.destroy if df.present?
  end

  # Validation to ensure a MatrixQuestion contains at least one ChoiceQuestion
  def has_choice_questions
    self.errors.add(:base, "Matrix questions must have at least one question") if self.choice_questions.empty? or self.choice_questions.all? {|q| q.marked_for_destruction? or q.question_content.marked_for_destruction? }
  end

  # MatrixQuestions need to rebuild the ChoiceAnswers on update. This method does this after validation.
  def remove_old_answers
    if self.valid?
      self.choice_questions.includes(:choice_answers).each {|x| x.choice_answers.each(&:destroy)}
    end
  end
end

# == Schema Information
#
# Table name: matrix_questions
#
#  id                :integer          not null, primary key
#  created_at        :datetime
#  updated_at        :datetime
#  survey_version_id :integer
#  clone_of_id       :integer
#
