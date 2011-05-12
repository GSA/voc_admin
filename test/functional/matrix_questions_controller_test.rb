require 'test_helper'

class MatrixQuestionsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => MatrixQuestion.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    MatrixQuestion.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    MatrixQuestion.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to matrix_question_url(assigns(:matrix_question))
  end

  def test_edit
    get :edit, :id => MatrixQuestion.first
    assert_template 'edit'
  end

  def test_update_invalid
    MatrixQuestion.any_instance.stubs(:valid?).returns(false)
    put :update, :id => MatrixQuestion.first
    assert_template 'edit'
  end

  def test_update_valid
    MatrixQuestion.any_instance.stubs(:valid?).returns(true)
    put :update, :id => MatrixQuestion.first
    assert_redirected_to matrix_question_url(assigns(:matrix_question))
  end

  def test_destroy
    matrix_question = MatrixQuestion.first
    delete :destroy, :id => matrix_question
    assert_redirected_to matrix_questions_url
    assert !MatrixQuestion.exists?(matrix_question.id)
  end
end
