class RemoveFlowControlFromQuestionBankQuestions < ActiveRecord::Migration
  def self.up
    QuestionBank.instance.questions.each do |q|
      if q.is_a?(ChoiceQuestion) && q.flow_control
        q.question_content.update_attributes!(flow_control: false)

        ChoiceQuestion.where(clone_of_id: q.id).find_each do |cq|
          cq.question_content.update_attributes!(flow_control: false)
        end
      end
    end
  end
end
