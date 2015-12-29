module FeatureHelper
  ADMIN_HHS_ID = 2001149591
  def login_user
    create_admin_user
    visit login_path
    find(:xpath, "//a[@href='/login?user_id=#{ADMIN_HHS_ID}']").click
  end

  def create_admin_user
    User.find_by_hhs_id(ADMIN_HHS_ID) ||
      FactoryGirl.create(:user, :admin, hhs_id: ADMIN_HHS_ID)
  end

  def create_site
    visit sites_path
    first(:link, "New Site").click
    fill_in "Name:", with: "Test"
    fill_in "site_url", with: "http://test.com"
    fill_in "Description:", with: "Test Description"
    click_button "Create Site"
    expect(page).to have_content("Edit")
  end

  def create_survey_types
    SurveyType.create id: SurveyType::POLL, name: "Poll"
    SurveyType.create id: SurveyType::SITE, name: "Site"
    SurveyType.create id: SurveyType::PAGE, name: "Page"
  end

  def create_survey survey_type: "Site"
    create_survey_types
    visit root_path
    click_link "Create New Survey"
    fill_in "Name:", with: "Test Survey"
    fill_in "Description:", with: "Test Survey Description"
    select "Test", from: "survey_site_id"
    select survey_type, from: "survey_survey_type_id"
    click_button "Create Survey"
  end

end
