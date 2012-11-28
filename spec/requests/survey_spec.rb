require 'spec_helper'

describe Survey do

  # GET /surveys
  describe "GET /surveys" do
    it 'should redirect to the login page when a user has not been logged in' do
      visit surveys_path
      current_path.should == login_path
    end

    context 'when logged in' do
      it 'should not redirect to login page' do
        sign_in(:user)
        visit surveys_path
        current_path.should == surveys_path
      end

      context "as admin" do
        before(:each) { sign_in(:admin) }

        it 'should list available surveys' do
          survey = create :survey

          visit surveys_path
          page.should have_content(survey.name)
        end
      end # as admin

      context "as user" do
        before(:each) { sign_in(:user) }

        it 'should list only surveys for the sites the user is allowed to see' do
          allowed_survey = create :survey
          restricted_survey = create :survey

          @user.site_ids = [allowed_survey.site_id]

          visit surveys_path

          page.should have_content allowed_survey.name
          page.should_not have_content restricted_survey.name
        end
      end # as user

    end # when logged in

  end # GET /surveys
end

def sign_in(role = :admin)
  @user = create :user

  @user.update_attribute(:role_id, Role::ADMIN.id) if role == :admin

  visit login_path
  fill_in "user_session_email", with: @user.email
  fill_in "user_session_password", with: "password"
  click_button "Login"
end