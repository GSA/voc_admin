class AddQcIdToQuestionReporters < ActiveRecord::Migration
  def self.up
    # SurveyVersionReporter.all.each do |svr|
    #   svr.text_question_reporters.each do |tqr|
    #     tqr.qc_id = tqr.question.question_content.id
    #   end
    #   svr.choice_question_reporters.each do |cqr|
    #     cqr.qc_id = cqr.question.question_content.id
    #   end
    #   svr.save
    # end
  end

  def self.down
  end
end
