require 'spec_helper'

describe "Login" do
  let(:user) do
    User.create!(
      email: "email@example.com",
      password: "password",
      password_confirmation: "password",
      role_id: Role::ADMIN,
      f_name: "Example",
      l_name: "User"
    )
  end

  it 'should log the user in' do
    login_user(user.email, "password")

    page.should have_content(user.email)
  end

  it 'should redirect the user to the surveys_path after successful login' do
    login_user(user.email, "password")
    assert current_path == surveys_path
  end

  it 'should rerender the login template with invalid email' do
    login_user("invalid@example.com", "password")
    current_path.should == user_sessions_path
  end

  it 'should rerender the login template with invalid password' do
    login_user(user.email, "invalid_password")
    current_path.should == user_sessions_path
  end

  it 'should render the same error message for invalid emails as invalid passwords' do
    error_text = "Email/Password combination is not valid"
    login_user("invalid@example.com", "password")
    page.should have_content(error_text)

    login_user(user.email, "invalid_password")
    page.should have_content(error_text)
  end
end

def login_user(email, password)
  visit login_path

  fill_in "user_session_email", with: email
  fill_in "user_session_password", with: password
  click_button "Login"
end