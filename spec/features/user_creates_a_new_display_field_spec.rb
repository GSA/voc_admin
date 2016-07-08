require "rails_helper"

RSpec.feature "User creates a new display field", js: true do
  scenario "with valid attributes" do
    login_user
    create_site
    setup_survey name: "Example"
    load_responses_for survey_name: "Example", version_number: "1.0"

    click_link "Manage Display Fields", match: :first
    click_link "Add New Display Field", match: :first
    fill_in "Name", with: "Custom Display Field"
    click_button "Create Display Field"

    expect(page).to have_css "tr", text: "Custom Display Field"
  end

  scenario "with invalid attributes" do
    login_user
    create_site
    setup_survey name: "Example"
    load_responses_for survey_name: "Example", version_number: "1.0"

    click_link "Manage Display Fields", match: :first
    click_link "Add New Display Field", match: :first
    fill_in "Name", with: ""
    click_button "Create Display Field"

    expect(page).to have_content "can't be blank"
  end
end
