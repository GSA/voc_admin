class ChoiceQuestion < ActiveRecord::Base
  has_one :survey_element, :as => :assetable, :dependent => :destroy
  has_one :question_content, :as => :questionable, :dependent => :destroy
  has_many :choice_answers, :dependent => :destroy
  belongs_to :matrix_question

  # answer_type is how to display the choices.  radio buttons or check boxes
  validates :answer_type, :presence => true
  validates :question_content, :presence => true
  validate :must_have_at_least_one_choice_answer
  validate :only_one_default_answer, :if=> Proc.new {|obj| obj.answer_type == "radio" || obj.answer_type == "dropdown"}

  attr_accessible :answer_type, :question_content_attributes, :survey_element_attributes, :choice_answers_attributes, :clone_of_id, :choice_answers, :auto_next_page, :display_results, :answer_placement

  accepts_nested_attributes_for :question_content, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :survey_element
  accepts_nested_attributes_for :choice_answers, :allow_destroy => true, :reject_if => proc { |obj| obj['answer'].blank? }

  delegate :statement, :required, :flow_control, :to => :question_content

  HORIZONTAL_PLACEMENT = false
  VERTICAL_PLACEMENT = true

  def only_one_default_answer
    defaults = self.choice_answers.map{|ca| ca.is_default}.reject{|is_default| is_default == false}
    errors.add_to_base("#{answer_type.titlecase} style questions can have only one default answer") if(defaults.size > 1)
  end

  def survey_version
    self.survey_element.nil? ? self.matrix_question.survey_version : self.survey_element.survey_version
    # self.survey_element.survey_version if self.survey_element
    # self.matrix_question.survey_version if self.matrix_question
  end

  def get_true_value(answer_string)
    ChoiceAnswer.find(answer_string.split(",")).map { |ca| ca.answer }.join("{%delim%}")
  end

  def check_condition(survey_response, conditional_id, test_value)
    #check the survey_response for a response to this quesiton
    raw_response = survey_response.raw_responses.detect {|rr| rr.question_content_id == self.question_content.id}
    return(false) unless raw_response
    answer = raw_response.answer

    case conditional_id
    when 1 #"="
      answer == test_value
    when 2 #"!="
      answer != test_value
    when 3 #"contains"
      answer.include? test_value
    when 4 #"does not contain"
      !answer.include? test_value
    when 5 #"<"
      answer.to_i < test_value.to_i
    when 6 #"<="
      answer.to_i <= test_value.to_i
    when 7 #">="
      answer.to_i >= test_value.to_i
    when 8 #">"
      answer.to_i > test_value.to_i
    when 9 #"empty"
      answer.blank?
    when 10 #"not empty"
      !answer.blank?
    else
      false
    end
  end

  def clone_me(target_sv)
    return unless self.survey_element
    #build question content
    qc_attribs = self.question_content.attributes
    qc_attribs.delete("id")

    #build Survey Element
    se_attribs = self.survey_element.attributes.merge(
      :survey_version_id=>target_sv.id,
      :page_id=>(target_sv.pages.find_by_clone_of_id(self.survey_element.page_id).id))
    se_attribs.delete("id")

    #build Choice Answers
    ca_attribs = self.choice_answers.map do |choice_answer|
      answer_hash = choice_answer.attributes.merge(
        :clone_of_id=>(choice_answer.id))
      answer_hash.delete("id")

      #update the next page pointer
      if answer_hash["next_page_id"]
        answer_hash["next_page_id"] = (Page.find_by_survey_version_id_and_clone_of_id( target_sv.id, choice_answer.next_page_id).id)
      end
      answer_hash
    end

    #save it all
    ChoiceQuestion.create!(self.attributes.merge(
                             :question_content_attributes=>qc_attribs.merge(:skip_observer => true),
                             :survey_element_attributes=>se_attribs,
                             :choice_answers_attributes=>ca_attribs,
                             :clone_of_id => (self.id)))
  end

  def copy_to_page(page)
    return unless self.survey_element
    #build question content
    qc_attribs = self.question_content.attributes
    qc_attribs = qc_attribs.merge(:statement => "#{self.question_content.statement} (copy)")
    qc_attribs.delete("id")

    #build Survey Element
    se_attribs = self.survey_element.attributes.merge(:page_id=>page.id)
    se_attribs.delete("id")

    #build Choice Answers
    ca_attribs = self.choice_answers.map do |choice_answer|
      answer_hash = choice_answer.attributes.merge(:clone_of_id=>nil)
      answer_hash.delete("id")

      #update the next page pointer (clear the pointers since new question is on new page and linking would be invalid)
      if answer_hash["next_page_id"]
        answer_hash["next_page_id"] = nil
      end
      answer_hash
    end

    #save it all
    ChoiceQuestion.create!(self.attributes.merge(
                             :question_content_attributes=>qc_attribs,
                             :survey_element_attributes=>se_attribs,
                             :choice_answers_attributes=>ca_attribs,
                             :clone_of_id => nil))
  end

  private
  def must_have_at_least_one_choice_answer
    self.errors.add(:base, "must have at least one answer.") if self.choice_answers.empty? or self.choice_answers.all? {|ca| ca.marked_for_destruction?}
  end
end


# == Schema Information
#
# Table name: choice_questions
#
#  id                 :integer(4)      not null, primary key
#  multiselect        :boolean(1)
#  answer_type        :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  matrix_question_id :integer(4)
#  clone_of_id        :integer(4)
#  auto_next_page     :boolean(1)
#  display_results    :boolean(1)
#
