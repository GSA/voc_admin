class QuestionBank::ChoiceQuestionsController < ApplicationController
  def new
    @choice_question = ChoiceQuestion.new
  end

  def create
    @choice_question = ChoiceQuestion.new params[:choice_question]
    @choice_question.question_content.skip_observer = true
    if @choice_question.save
      QuestionBank.instance.choice_questions << @choice_question
      redirect_to question_bank_path
    else
      render :new
    end
  end
end