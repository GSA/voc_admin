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

  def edit
    @choice_question = ChoiceQuestion.find params[:id]
  end

  def update
    @choice_question = ChoiceQuestion.find params[:id]
    @choice_question.question_content.skip_observer = true

    if @choice_question.update_attributes(params[:choice_question])
      redirect_to question_bank_path
    else
      render :edit
    end
  end

  def destroy
    @choice_question = ChoiceQuestion.find params[:id]
    @choice_question.destroy
    redirect_to question_bank_path
  end
end