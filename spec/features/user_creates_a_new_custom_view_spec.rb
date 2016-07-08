require "rails_helper"

RSpec.feature "User creates a new custom view", js: true do
  scenario "with valid attributes" do
    login_user
    create_site
    survey = setup_survey name: "Example"
    load_responses_for survey_name: "Example", version_number: "1.0"
    FactoryGirl.create :text_question,
      survey_version: survey.survey_versions.first,
      question_content: create(:question_content, statement: "Text Question")

    click_link "Add New View", match: :first
    fill_in "Name", with: "Custom View"
    choose "No"
    select "Text Question", from: "available_display_fields"
    click_link "ADD >>"
    click_button "Create Custom View"

    expect(page).to have_select "Select View", options: ["Standard View", "Custom View"]
  end

  scenario "with invalid attributes" do
    login_user
    create_site
    survey = setup_survey name: "Example"
    load_responses_for survey_name: "Example", version_number: "1.0"
    FactoryGirl.create :text_question,
      survey_version: survey.survey_versions.first,
      question_content: create(:question_content, statement: "Text Question")

    click_link "Add New View", match: :first
    fill_in "Name", with: ""
    choose "No"
    select "Text Question", from: "available_display_fields"
    click_link "ADD >>"
    click_button "Create Custom View"

    expect(page).to have_content "can't be blank"
  end
end
