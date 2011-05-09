require 'test_helper'

class DisplayFieldValuesControllerTest < ActionController::TestCase
  def test_edit
    get :edit, :id => DisplayFieldValue.first
    assert_template 'edit'
  end

  def test_update_invalid
    DisplayFieldValue.any_instance.stubs(:valid?).returns(false)
    put :update, :id => DisplayFieldValue.first
    assert_template 'edit'
  end

  def test_update_valid
    DisplayFieldValue.any_instance.stubs(:valid?).returns(true)
    put :update, :id => DisplayFieldValue.first
    assert_redirected_to root_url
  end
end
