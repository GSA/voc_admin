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

    scenario "User adds a text question with invalid attributes" do
      login_user
      create_site
      create_survey
      add_text_question statement: ""
      expect(page).to_not have_css ".page_asset"
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

    scenario "User adds a choice question with invalid attributes" do
      login_user
      create_site
      create_survey
      add_choice_question statement: "", answer: "foo"
      expect(page).to_not have_css ".page_asset"
    end
  end

  context "matrix question" do
    scenario "User adds a matrix question with valid attributs" do
      login_user
      create_site
      create_survey
      add_matrix_question statement: "Example QUestion",
        questions: ["Question 1"],
        answers: ["foo", "bar"]
      expect(page).to have_css ".page_asset"
    end

    scenario "User adds an invalid matrix question" do
      login_user
      create_site
      create_survey
      add_matrix_question statement: "",
        questions: ["Question 1"],
        answers: ["foo", "bar"]
      expect(page).to_not have_css ".page_asset"
    end
  end

  def add_matrix_question statement:, questions:, answers:
    click_link "Add matrix question"
    fill_in "Statement:", with: statement
    page.all(:css, ".ChoiceQuestionContent textarea").zip(questions).each do |element, value|
      fill_in element[:name], with: value
    end
    page.all(:css, ".answer_fields input").zip(answers).each do |element, value|
      fill_in element[:name], with: value
    end
    click_button "Create Question"
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
