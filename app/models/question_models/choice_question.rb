# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Choice Questions can act as standalone questions of several types (radio, checkbox, dropdown, multiselect)
# or be part of a MatrixQuestion (radio only)
class ChoiceQuestion < ActiveRecord::Base
  require 'condition_tester'

  has_one :survey_element, :as => :assetable, :dependent => :destroy
  has_one :question_content, :as => :questionable, :dependent => :destroy
  has_many :choice_answers, :dependent => :destroy, :autosave => true
  belongs_to :matrix_question

  has_many :question_bank_questions, as: :bankable, dependent: :destroy
  has_many :question_banks, through: :question_bank_questions

  # answer_type is how to display the choices.
  validates :answer_type, :presence => true
  validates :question_content, :presence => true
  validate :must_have_at_least_one_choice_answer
  validate :only_one_default_answer, :unless => Proc.new { |obj| obj.allows_multiple_selection }

  attr_accessible :answer_type, :question_content_attributes,
    :survey_element_attributes, :choice_answers_attributes, :clone_of_id,
    :choice_answers, :auto_next_page, :display_results, :answer_placement,
    :multiselect, :matrix_question_id

  accepts_nested_attributes_for :question_content, :allow_destroy => true
  accepts_nested_attributes_for :survey_element
  accepts_nested_attributes_for :choice_answers, :allow_destroy => true,
    :reject_if => proc { |obj| obj['answer'].blank? }

  delegate :statement, :required, :flow_control, :flow_control?, :display_fields,
    :to => :question_content

  # Stored in answer_placement
  # Lays the ChoiceAnswer options out vertically.
  HORIZONTAL_PLACEMENT = false
  # Lays the ChoiceAnswer options out from left to right.
  VERTICAL_PLACEMENT = true

  # Verifies that only one "default" answer is selected across the question's associated answers.
  def only_one_default_answer
    defaults = self.choice_answers.map{|ca| ca.is_default}.reject{|is_default| is_default == false}
    if(defaults.size > 1)
      errors.add_to_base("#{answer_type.titlecase} style questions can have only one default answer")
    end
  end

  # If this is a standalone ChoiceQuestion, the contained SurveyElement will refer to the SurveyVersion; if part
  # of a MatrixQuestion, the parent MatrixQuestion will be the source for the SurveyVersion reference.
  #
  # @return [SurveyVersion] the SurveyVersion by association
  def survey_version
    self.survey_element.nil? ? self.matrix_question.try(:survey_version) : self.survey_element.try(:survey_version)
  end

  # Looks up from the DB and composes a safetied string of ChoiceAnswer values.
  # Used for checkbox ChoiceQuestions.
  #
  # @param [String] answer_string a comma-delimited string of ChoiceAnswer ids
  # @return [String] a custom-delimited string of ChoiceAnswer.answer field values
  def get_true_value(answer_string)
    ChoiceAnswer.find(answer_string.split(",")).map { |ca| ca.answer }.join("{%delim%}")
  end

  # Used by Criteria in Rules to process survey_responses against Conditionals
  #
  # @param [SurveyResponse] survey_response a SurveyResponse to test
  # @param [Integer] conditional_id the operator used to test
  # @param [Object] test_value the value to test
  def check_condition(survey_response, conditional_id, test_value)
    #check the survey_response for a response to this question
    raw_response = survey_response.raw_responses.detect {|rr| rr.question_content_id == self.question_content.id}
    return(false) unless raw_response
    answer = raw_response.answer

    ConditionTester.test(conditional_id, answer, test_value)
  end

  # Makes a deep copy of the ChoiceQuestion (when cloning a Page)
  #
  # @param [SurveyVersion] target_sv the SurveyVersion destination
  # @return [ChoiceQuestion] the cloned ChoiceQuestion
  def clone_me(target_sv, target_page = nil, sv_clone = true)
    return unless self.survey_element
    #build question content
    qc_attribs = self.question_content.attributes
      .except("id", "created_at", "updated_at", "questionable_id")

    target_page ||= target_sv.pages.find_by_clone_of_id(self.survey_element.page_id)

    #build Survey Element
    se_attribs = self.survey_element.attributes
      .except("id", "created_at", "updated_at")
      .merge(
        :survey_version_id=>target_sv.id,
        :page_id=>target_page.id
      )

    #build Choice Answers
    ca_attribs = self.choice_answers.map do |choice_answer|
      answer_hash = choice_answer.attributes
        .except("id", "created_at", "updated_at")
        .merge(
          :clone_of_id=>(choice_answer.id)
        )

      #update the next page pointer
      if answer_hash["next_page_id"]
        answer_hash["next_page_id"] = (Page.find_by_survey_version_id_and_clone_of_id( target_sv.id,
          choice_answer.next_page_id).id)
      end
      answer_hash
    end
    cloneable_attributes = self.attributes.except("id", "updated_at", "created_at")
    choice_question = ChoiceQuestion.new cloneable_attributes.merge(
     :question_content_attributes=>qc_attribs.merge(:skip_observer => true),
     :survey_element_attributes=>se_attribs,
     :choice_answers_attributes=>ca_attribs,
     :clone_of_id => (self.id)
    )

    choice_question.save!
    choice_question
  end

  # Makes a deep copy of the ChoiceQuestion (when cloning a page)
  #
  # @param [Page] page the page to be cloned onto
  # @return [ChoiceQuestion] the cloned copy
  def copy_to_page(page)
    return unless self.survey_element
    #build question content
    qc_attribs = self.question_content.attributes
      .except("id", "created_at", "updated_at", "questionable_id")
      .merge("statement" => "#{self.question_content.statement} (copy)", "flow_control" => false)

    #build Survey Element
    se_attribs = self.survey_element.attributes
      .except("id", "created_at", "updated_at")
      .merge("page_id"=>page.id)

    #build Choice Answers
    ca_attribs = self.choice_answers.map do |choice_answer|
      answer_hash = choice_answer.attributes
        .except("id", "created_at", "updated_at")
        .merge("clone_of_id"=>nil)

      #update the next page pointer (clear the pointers since new question is on new page and linking would be invalid)
      if answer_hash["next_page_id"]
        answer_hash["next_page_id"] = nil
      end
      answer_hash
    end

    #save it all
    ChoiceQuestion.create!(self.attributes
      .except("id", "created_at", "updated_at")
      .merge(
        "question_content_attributes"=>qc_attribs,
        "survey_element_attributes"=>se_attribs,
        "choice_answers_attributes"=>ca_attribs,
        "clone_of_id" => nil
      )
    )
  end

  def reporter
    SurveyVersionReporter.find_choice_question_reporter(self)
  end

  def allows_multiple_selection
    ["checkbox", "multiselect"].include?(answer_type)
  end

  def describe_me(assetable_type, element_order)
    {id: id,
     assetable_type: assetable_type,
     element_order: element_order,
     statement: question_content.statement,
     required: question_content.required,
     flow_control: question_content.flow_control,
     multiselect: multiselect,
     answer_type: answer_type,
     matrix_question_id: matrix_question_id,
     clone_of_id: clone_of_id,
     auto_next_page: auto_next_page,
     display_results: display_results,
     answer_placement: answer_placement,
     choice_answers: choice_answers.map(&:describe_me)}.reject {|k, v| v.blank? }
  end

  private
  # Validation to ensure that a ChoiceQuestion is not created without at least one ChoiceAnswer.
  def must_have_at_least_one_choice_answer
    self.errors.add(:base, "must have at least one answer.") if self.choice_answers.empty? or self.choice_answers.all? {|ca| ca.marked_for_destruction?}
  end

  # Validation to ensure that there is, at most, one answer marked as default.
  def only_one_default_answer
    errors.add_to_base("#{answer_type.titlecase} style questions can have only one default answer") if self.choice_answers.select(&:is_default).count > 1
  end

end

# == Schema Information
#
# Table name: choice_questions
#
#  id                 :integer          not null, primary key
#  multiselect        :boolean
#  answer_type        :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  matrix_question_id :integer
#  clone_of_id        :integer
#  auto_next_page     :boolean
#  display_results    :boolean
#  answer_placement   :boolean
#
