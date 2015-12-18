require "rails_helper"

RSpec.feature "Survey builder", js: true do
  context "text question" do
    scenario "User adds a text question with valid attributes" do
      login_user
      create_site
      create_survey
      add_text_question statement: "Example Question"
      expect(page).to have_css ".page_asset", text: "Example Question", count: 1
    end
  end

  context "choice question" do
    scenario "User adds a choice question with valid attributes" do
      login_user
      create_site
      create_survey
      add_choice_question statement: "Example Question", answer: "foo"
      expect(page).to have_css(".page_asset", text: "Example Question", count: 1)
    end
  end

  def add_choice_question statement:, answer:
    click_link "Add a multiple-choice question"
    fill_in "Question:", with: statement
    fill_in "Answer:", with: answer, match: :first
    click_button "Create Question"
  end

  def add_text_question statement
    click_link "Add an open-ended question"
    choose "Field"
    fill_in "Question:", with: statement
    click_button "Create Question"
  end
end
