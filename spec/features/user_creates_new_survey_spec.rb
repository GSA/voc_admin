require "rails_helper"

feature "User creates a new survey" do
  scenario "they see the survey edit page" do
    survey_name = "Test Survey"
    survey_description = "This is a test survey"
    create_test_site
    login_user

    visit root_path
    click_on "New Survey", match: :first
    fill_in "survey_name", with: survey_name
    fill_in "survey_description", with: survey_description
    select "Test Survey", from: "survey_site_id"
    click_on "Create Survey"

    expect(page).to have_link "Test Survey"
  end

  context "without all required fields" do
    scenario "they see a useful error message" do
      survey_name = "Invalid Survey"
      create_test_site
      login_user

      visit root_path
      click_on "New Survey", match: :first
      fill_in "survey_name", with: survey_name
      click_on "Create Survey"
      expect(page).to have_content "Description can't be blank"
    end
  end

end
