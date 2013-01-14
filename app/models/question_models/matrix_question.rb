# == Schema Information
# Schema version: 20110524182200
#
# Table name: matrix_questions
#
#  id                :integer(4)      not null, primary key
#  created_at        :datetime
#  updated_at        :datetime
#  survey_version_id :integer(4)
#  clone_of_id       :integer(4)
#

class MatrixQuestion < ActiveRecord::Base
  has_one :survey_element, :as => :assetable, :dependent => :destroy
  has_one :question_content, :as => :questionable, :dependent => :destroy
  has_many :choice_questions
  belongs_to :survey_version

  accepts_nested_attributes_for :question_content, :allow_destroy => false, :reject_if => proc { |obj| obj[:statement].blank? }
  accepts_nested_attributes_for :choice_questions, :allow_destroy => true, :reject_if => proc { |obj| obj[:question_content_attributes][:statement].blank? }
  accepts_nested_attributes_for :survey_element


  validates :question_content, :presence => true
  validate :has_choice_questions

  after_validation :remove_old_answers

  delegate :statement, :statement=, :required, :to => :question_content

  def column_headers
    return [] if self.choice_questions.empty?
    self.choice_questions.limit(1).first.choice_answers.map {|a| a.answer}
  end

  def rows
    self.choice_questions.includes(:question_content).includes(:choice_answers)
  end

  # def required
  #   self.choice_questions.includes(:question_content).inject(true) {|memo, q| memo && q.required }
  # end

  def answer_type
    "matrix"
  end

  def clone_me(target_sv)
    #start matrix hash
    mq_qc_attribs = self.question_content.attributes
    mq_qc_attribs.delete("id")
    mq_attribs = self.attributes.merge(
                  :clone_of_id => (self.id),
                  :survey_version_id => (target_sv.id),
                  :question_content_attributes => mq_qc_attribs
                 )
    mq_attribs.delete("id")
    mq_attribs.delete("statement")

    #build se hash
    se_attribs = self.survey_element.attributes.merge(
                  :survey_version_id => target_sv.id,
                  :page_id => (target_sv.pages.find_by_clone_of_id(self.survey_element.page_id).id)
                 )
    se_attribs.delete("id")

    #build content question hash
    choice_questions = self.choice_questions.map do |choice_question|
      qc_attribs = choice_question.question_content.attributes.merge({:matrix_statement => self.statement, :skip_observer => true})
      qc_attribs.delete("id")

      cq_attribs = choice_question.attributes
      cq_attribs.delete("id")
      ca_attribs = choice_question.choice_answers.map do |choice_answer|
        answer_hash = choice_answer.attributes.merge(
                        :clone_of_id => (choice_answer.id)
                      )
        answer_hash.delete("id")

        #update the next page pointer
        if answer_hash["next_page_id"]
          answer_hash["next_page_id"] = (Page.find_by_survey_version_id_and_clone_of_id( target_sv.id, new_answer.next_page_id).id)
        end
        answer_hash
      end
      cq_attribs = cq_attribs.merge(
                    :question_content_attributes => qc_attribs,
                    :choice_answers_attributes => ca_attribs,
                    :clone_of_id => (choice_question.id),
                    :skip_observer => true
                   )
    end

    mq_attribs = mq_attribs.merge(:choice_questions_attributes => choice_questions, :survey_element_attributes => se_attribs)
    MatrixQuestion.create!(mq_attribs)
  end

  def copy_to_page(page)
    #start matrix hash
    mq_qc_attribs = self.question_content.attributes
    mq_qc_attribs.delete("id")
    mq_attribs = self.attributes.merge(:clone_of_id => nil, :question_content_attributes => mq_qc_attribs.merge(:statement => "#{self.question_content.statement} (copy)"))
    mq_attribs.delete("id")


    #build se hash
    se_attribs = self.survey_element.attributes.merge(:page_id => page.id)
    se_attribs.delete("id")

    #build content question hash
    choice_questions = self.choice_questions.map do |choice_question|
      qc_attribs = choice_question.question_content.attributes.merge({:matrix_statement => "#{self.question_content.statement} (copy)"})
      qc_attribs = qc_attribs.merge(:statement => "#{choice_question.question_content.statement} (copy)")
      qc_attribs.delete("id")

      cq_attribs = choice_question.attributes
      cq_attribs.delete("id")
      ca_attribs = choice_question.choice_answers.map do |choice_answer|
        answer_hash = choice_answer.attributes.merge(
          :clone_of_id => nil
        )
        answer_hash.delete("id")

        #update the next page pointer
        if answer_hash["next_page_id"]
          answer_hash["next_page_id"] = nil #clear pointer since copied question pointers would be invalid
        end
        answer_hash
      end
      cq_attribs = cq_attribs.merge(
                    :question_content_attributes => qc_attribs,
                    :choice_answers_attributes => ca_attribs,
                    :clone_of_id => (choice_question.id)
                   )
    end

    mq_attribs = mq_attribs.merge(:choice_questions_attributes => choice_questions, :survey_element_attributes => se_attribs)
    MatrixQuestion.create!(mq_attribs)
  end

  private
  def has_choice_questions
    self.errors.add(:base, "Matrix questions must have at least one question") if self.choice_questions.empty? or self.choice_questions.all? {|q| q.marked_for_destruction? or q.question_content.marked_for_destruction? }
  end

  def remove_old_answers
    self.choice_questions.includes(:choice_answers).each {|x| x.choice_answers.each(&:destroy)}
  end
end
