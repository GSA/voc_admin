require "rails_helper"

RSpec.feature "User creates a new rule", js: true do
  scenario "with valid attributes" do
    login_user
    create_site
    survey = setup_survey name: "Example"
    load_responses_for survey_name: "Example", version_number: "1.0"

    click_link "Manage Rules", match: :first
    click_link "Add New Rule", match: :first
    fill_in "Name", with: "Custom Rule"
    choose "db_action_rule"
    check "Add"
    select "", from: "Source select"
    select "", from: "Conditional"
    fill_in "Value", with: "Test"
    fill_in "value_text", with: "Test"
    click_button "Create Rule"

    expect(page).to have_content "Custom Rule"
  end

  scenario "with invalid attributes" do

  end
end
