require 'spec_helper'

describe Survey do

  # GET /surveys
  describe "GET /surveys" do
    it 'should redirect to the login page when a user has not been logged in' do
      visit surveys_path
      current_path.should == login_path
    end

    context 'when logged in' do
      context "as admin" do
        it 'should list all available surveys' do
          sign_in(:admin)
          survey = create :survey
          visit surveys_path
          current_path.should == surveys_path
          page.should have_content(survey.name)
        end
      end # as admin

      context "as user" do
        before(:each) { sign_in(:user) }

        it 'should not redirect to login page' do
          visit surveys_path
          current_path.should == surveys_path
        end

        it 'should list only surveys for the sites the user is allowed to see' do
          allowed_survey = create :survey
          restricted_survey = create :survey
              
          @user.site_ids = [allowed_survey.site_id]
              
          visit surveys_path
              
          page.should have_content allowed_survey.name
          page.should_not have_content restricted_survey.name
        end
        
        it 'should take you to the survey_responses page when you click on the survey name' do
          survey = create :survey
          
          @user.site_ids = [survey.site_id]
          
          visit surveys_path
          
          page.should have_link(survey.name)
          click_link survey.name
          current_path.should == survey_responses_path
        end
        
      end # as user

    end # when logged in

  end # GET /surveys
  
  # GET /surveys/:id/edit
  context "edit survey" do
    it 'should have the required fields for editing' do
      survey = create :survey
      sign_in(:admin)
      current_path.should == surveys_path
      
      find("#surveyTable td.col1 a").click
      current_path.should == edit_survey_path(survey)
      
      page.should have_css("input#survey_name")
      page.should have_css("textarea#survey_description")
      page.should have_css("select#survey_site_id")
      page.should have_css("select#survey_survey_type_id")
    end
  end
  
  # PUT /surveys/:id
  context "updating survey" do
    before(:each) { 
      @survey = create(:survey)
      sign_in(:admin) 
    }
    
    it 'should update the survey information' do
      visit surveys_path
      survey_type = SurveyType.create! name: "Site"
      old_survey_type = @survey.survey_type.name
      
      find('#surveyTable td.col1 a').click # Col 1 should have the edit link.  
      current_path.should == edit_survey_path(@survey)
      
      fill_in "survey_name", with: "Updated Survey Name"
      fill_in "survey_description", with: "Updated Survey Description Field"
      page.select survey_type.name, from: 'survey_survey_type_id'
      
      click_button "Update Survey"
      
      current_path.should == surveys_path
      page.should have_content("Updated Survey Name")
      page.should have_content("Updated Survey Description Field")
      page.should have_content("Site")
      page.should_not have_content(@survey.name)
      page.should_not have_content(@survey.description)
      page.should_not have_content(old_survey_type)
    end
    
  end
  
  # POST /surveys
  it 'should create a new survey' do
    create :site
    SurveyType.create! :name => "Poll"
    sign_in(:admin)
    
    visit new_survey_path
    current_path.should == new_survey_path
    page.select(Site.first.name, :from => "survey_site_id")
    fill_in "survey_name", with: "Test Survey"
    fill_in "survey_description", with: "This is a test survey"
    page.select(SurveyType.first.name, from: "survey_survey_type_id")
    click_button "Create Survey"
    current_path.should == edit_survey_survey_version_path(survey_id: Survey.first, id: Survey.first.survey_versions.first)
  end
  
  # DELETE /surveys/:id
  it 'should destroy the survey' do
    survey = create :survey
    sign_in(:admin)
    
    visit surveys_path
    
    current_path.should == surveys_path
    
    expect {find('a.deleteLink').click}.to change {Survey.count}.by(-1)
  end
end

def sign_in(role)
  @user = create(:user, role)

  visit login_path
  fill_in "user_session_email", with: @user.email
  fill_in "user_session_password", with: "password"
  click_button "Login"
  
  @user
end
