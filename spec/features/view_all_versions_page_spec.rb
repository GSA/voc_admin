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
    find(:css, ".col11 a").click
    expect(page).to have_content "1.1"
  end
end
