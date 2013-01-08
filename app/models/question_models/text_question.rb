# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# The TextQuestion class can represent either a text field or a text area.
class TextQuestion < ActiveRecord::Base
  require 'condition_tester'

  has_one :survey_element, :as => :assetable, :dependent => :destroy
  has_one :question_content, :as => :questionable, :dependent => :destroy
  has_one :survey_version, :through => :survey_element
  
  validates :answer_type, :presence => true
  validates :question_content, :presence => true
  
  attr_accessible :answer_type, :question_content_attributes, :survey_element_attributes, :clone_of_id, :row_size, :answer_size
  accepts_nested_attributes_for :question_content
  accepts_nested_attributes_for :survey_element
  
  delegate :statement, :required, :flow_control, :to => :question_content
  
  default_scope includes(:question_content)
  
  # Delegated method for Questionable.
  def get_true_value(string_value)
    string_value
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

  # Makes a deep copy of the TextQuestion (when cloning a survey)
  # 
  # @param [SurveyVersion] target_sv the SurveyVersion destination
  # @return [TextQuestion] the cloned TextQuestion
  def clone_me(target_sv)
    qc_attribs = self.question_content.attributes.merge(:skip_observer => true)
    qc_attribs.delete("id")
    se_attribs = self.survey_element.attributes.merge(
                  :survey_version_id=>target_sv.id, 
                  :page_id=>(target_sv.pages.find_by_clone_of_id(self.survey_element.page_id).id)
                 )
    se_attribs.delete("id")
    cloned_question = TextQuestion.new(self.attributes.merge(
                        :question_content_attributes=>qc_attribs,
                        :survey_element_attributes=>se_attribs,
                        :clone_of_id => (self.id)
                      ))
    cloned_question.save!
    cloned_question
  end
  
  # Makes a deep copy of the TextQuestion (when cloning a Page)
  # 
  # @param [Page] page the page to be cloned onto
  # @return [TextQuestion] the cloned copy
  def copy_to_page(page)
      qc_attribs = self.question_content.attributes
      qc_attribs = qc_attribs.merge(:statement => "#{self.question_content.statement} (copy)")
      qc_attribs.delete("id")
      se_attribs = self.survey_element.attributes.merge(:page_id=>page.id)
      se_attribs.delete("id")
      TextQuestion.create!(self.attributes.merge(
                            :question_content_attributes=>qc_attribs,
                            :survey_element_attributes=>se_attribs,
                            :clone_of_id => nil
                          ))
    end
end

# == Schema Information
#
# Table name: text_questions
#
#  id          :integer(4)      not null, primary key
#  answer_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  clone_of_id :integer(4)
#  row_size    :integer(4)
#  column_size :integer(4)
#  answer_size :integer(4)
