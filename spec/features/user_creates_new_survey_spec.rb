require "rails_helper"

feature "User creates a new survey" do
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
