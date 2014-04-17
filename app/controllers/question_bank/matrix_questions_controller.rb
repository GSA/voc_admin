class QuestionBank::MatrixQuestionsController < ApplicationController
  def new
    @matrix_question = MatrixQuestion.new
  end

  def create
    choice_questions = params[:matrix_question][:choice_questions_attributes]

    choice_answer_attributes = params[:choice_answer_attributes] || {}
    choice_questions.each {|key, value| value.merge!({:choice_answers_attributes => choice_answer_attributes, :answer_type => "radio"})}

    @matrix_question = MatrixQuestion.new params[:matrix_question]

    # This sets a virtual attribute on each choice question's question content in order to create the correct name for display fields in the
    # after_create observer to get around the issue of the choice questions being saved before the matrix question's question content is saved
    # in the transaction.  This was causing matrix_question.statement to return an error in the after_create observer
    @matrix_question.choice_questions.each do |cq|
      cq.question_content.matrix_statement = @matrix_question.question_content.try(:statement)
    end

    if @matrix_question.save
      QuestionBank.instance.matrix_questions << @matrix_question
      redirect_to question_bank_path
    else
      render :new
    end
  end

  def edit
    @matrix_question = MatrixQuestion.find params[:id]
  end

  def update
    @matrix_question = MatrixQuestion.find(params[:id])
    choice_questions = params.fetch(:matrix_question, {})
      .fetch(:choice_questions_attributes, {})

    choice_answer_attributes = params[:choice_answer_attributes] || {}
    choice_questions.each {|key, value|
      value.deep_merge!({
        :choice_answers_attributes => choice_answer_attributes,
        :answer_type => "radio",
        :question_content_attributes => {
          :matrix_statement => @matrix_question.question_content.try(:statement),
          :skip_observer => true
        }
      })
    }

    if @matrix_question.update_attributes(params[:matrix_question])
      @matrix_question.remove_deleted_sub_questions(choice_questions)
      redirect_to question_bank_path
    else
      render :edit
    end
  end

  def destroy
    @matrix_question = MatrixQuestion.find params[:id]
    @matrix_question.destroy
    redirect_to question_bank_path
  end
end