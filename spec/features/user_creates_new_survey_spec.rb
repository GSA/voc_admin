require "rails_helper"

feature "User creates a new survey" do
  scenario "they see the survey edit page" do
    survey_name = "Test Survey"
    survey_description = "This is a test survey"
    site = FactoryGirl.create :site
    login_user

    visit root_path
    click_on "New Survey", match: :first
    fill_in "survey_name", with: survey_name
    fill_in "survey_description", with: survey_description
    select site.name, from: "survey_site_id"
    click_on "Create Survey"

    expect(page).to have_css "h1", text: "Edit Survey Version"
    expect(page).to have_text survey_name
  end

  context "without all required fields" do
    scenario "they see a useful error message" do
      survey_name = "Invalid Survey"
      site = FactoryGirl.create :site
      login_user

      visit root_path
      click_on "New Survey", match: :first
      fill_in "survey_name", with: survey_name
      click_on "Create Survey"
      expect(page).to have_content "Description can't be blank"
    end
  end

end
