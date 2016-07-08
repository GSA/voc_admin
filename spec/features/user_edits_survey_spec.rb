require "rails_helper"

RSpec.feature "User edits survey version" do
  scenario "they are able to add text questions to the survey", js: true do
    login_user
    create_site
    create_survey
    create_open_ended_question
    expect(page).to have_css(".page_asset")
  end

  def create_open_ended_question
    click_link "Add an open-ended question"
    choose "Field"
    fill_in "Question:", with: "Example Text Question"
    click_button "Create Question"
  end
end
