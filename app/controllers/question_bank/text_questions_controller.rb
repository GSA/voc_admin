class QuestionBank::TextQuestionsController < ApplicationController
  def new
    @text_question = TextQuestion.new
  end

  def create
    @text_question = TextQuestion.new params[:text_question]
    @text_question.question_content.skip_observer = true

    if @text_question.save
      QuestionBank.instance.text_questions << @text_question
      redirect_to question_bank_path
    else
      render :new
    end
  end
end