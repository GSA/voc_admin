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

  def edit
    @text_question = QuestionBank.instance.text_questions.find params[:id]
  end

  def update
    @text_question = TextQuestion.find params[:id]
    @text_question.question_content.skip_observer = true

    if @text_question.update_attributes(params[:text_question])
      redirect_to question_bank_path
    else
      render :edit
    end
  end

  def destroy
    @text_question = TextQuestion.find params[:id]
    @text_question.destroy
    redirect_to question_bank_path
  end
end
