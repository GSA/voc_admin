module FeatureHelper
  ADMIN_HHS_ID = 2001149591
  def login_user
    create_admin_user
    visit login_path
    #find(:xpath, "//a[@href='/login?user_id=#{ADMIN_HHS_ID}']").click
    fill_in "Username", with: "admin"
    fill_in "Password", with: "password"
    click_button "Login"
  end

  def create_admin_user
    User.find_by_username("admin") ||
      FactoryGirl.create(:user, :admin, username: "admin", password: "password")
#    User.find_by_hhs_id(ADMIN_HHS_ID) ||
      #FactoryGirl.create(:user, :admin, hhs_id: ADMIN_HHS_ID)
  end

  def create_site
    visit sites_path
    first(:link, "New Site").click
    fill_in "Name", with: "Test"
    fill_in "site_url", with: "http://test.com"
    fill_in "Description", with: "Test Description"
    click_button "Create Site"
    expect(page).to have_content("Edit")
  end

  def create_survey_types
    SurveyType.create id: SurveyType::POLL, name: "Poll"
    SurveyType.create id: SurveyType::SITE, name: "Site"
    SurveyType.create id: SurveyType::PAGE, name: "Page"
  end

  def create_survey survey_type: "Site", name: "Test Survey"
    create_survey_types
    visit root_path
    click_link "Create New Survey"
    fill_in "Name", with: name
    fill_in "Description", with: "Test Survey Description"
    select "Test", from: "survey_site_id"
    select survey_type, from: "survey_survey_type_id"
    click_button "Create Survey"
  end

  def setup_survey name:, site: FactoryGirl.create(:site),
    survey_type: FactoryGirl.create(:survey_type)
    FactoryGirl.create(:survey,
                       name: name,
                       site: site,
                       survey_type: survey_type
                      )
  end

  def load_responses_for survey_name:, version_number:
    visit survey_responses_path
    select survey_name, from: "survey_id"
    select version_number, from: "survey_version_id"
  end

  def create_test_survey_with_text_question statement:
    login_user
    create_site
    survey = setup_survey name: "Example"
    load_responses_for survey_name: "Example", version_number: "1.0"
    add_text_question survey_version: survey.survey_versions.first,
      statement: statement
  end

  def add_text_question survey_version:, statement:
    FactoryGirl.create(:text_question,
      survey_version: survey_version,
      question_content: FactoryGirl.create(:question_content, statement: statement)
    )
  end

end
