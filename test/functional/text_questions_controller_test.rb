require 'test_helper'

class TextQuestionsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => TextQuestion.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    TextQuestion.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    TextQuestion.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to text_question_url(assigns(:text_question))
  end

  def test_edit
    get :edit, :id => TextQuestion.first
    assert_template 'edit'
  end

  def test_update_invalid
    TextQuestion.any_instance.stubs(:valid?).returns(false)
    put :update, :id => TextQuestion.first
    assert_template 'edit'
  end

  def test_update_valid
    TextQuestion.any_instance.stubs(:valid?).returns(true)
    put :update, :id => TextQuestion.first
    assert_redirected_to text_question_url(assigns(:text_question))
  end

  def test_destroy
    text_question = TextQuestion.first
    delete :destroy, :id => text_question
    assert_redirected_to text_questions_url
    assert !TextQuestion.exists?(text_question.id)
  end
end
