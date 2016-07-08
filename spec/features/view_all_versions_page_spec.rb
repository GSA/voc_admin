require "rails_helper"

RSpec.feature "View all versions page" do
  scenario "User should see all versions" do
    survey = create :survey
    login_user
    visit survey_survey_versions_path(survey)
    expect(page).to have_css "#versionTable"
    expect(page).to have_content "1.0"
  end

  scenario "User should be able to create a new major version" do
    survey = create :survey
    login_user
    visit survey_survey_versions_path(survey)
    click_link "New Version", match: :first
    expect(page).to have_content "2.0"
  end

  scenario "User should be able to clone a new minor version" do
    survey = create :survey, name: "Example"
    login_user
    visit survey_survey_versions_path(survey)
    within find('tr', text: "1.0") do
      click_link "Clone Survey"
    end
    expect(page).to have_content "1.1"
  end

  scenario "User should be able to delete a version" do
    survey = create :survey
    login_user
    visit survey_survey_versions_path(survey)
    within find('tr', text: '1.0') do
      click_link "Delete"
    end
    expect(page).to_not have_content("1.0")
  end

  context "Survey version import" do
    scenario "with a valid import file" do
      survey = create :survey
      login_user
      visit survey_survey_versions_path(survey)
      attach_file "file", "spec/fixtures/survey_export.json"
      click_button "Import"
      expect(page).to have_content "2.0"
    end

    scenario "with invalid import file" do
      survey = create :survey
      login_user
      visit survey_survey_versions_path(survey)
      attach_file "file", "spec/fixtures/invalid_import.json"
      click_button "Import"
      expect(page).to_not have_content "2.0"
      expect(page).to have_content "Unable to import file."
    end
  end
end
