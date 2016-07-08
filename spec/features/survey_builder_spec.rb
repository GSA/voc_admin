require "rails_helper"

RSpec.feature "Survey builder", js: true do
  context "text question" do
    scenario "User adds a text question with valid attributes" do
      survey = create :survey
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      add_text_question statement: "Example Question"
      expect(page).to have_css ".page_asset", text: "Example Question", count: 1
    end

    scenario "User adds a text question with invalid attributes" do
      survey = create :survey
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      add_text_question statement: ""
      expect(page).to_not have_css ".page_asset"
    end

    scenario "User deletes a text question" do
      survey = create :survey
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      add_text_question statement: "Example Question"
      within find('div.page_asset', text: "Example Question") do
        click_link "Delete"
      end
      expect(page).to_not have_css ".page_asset", text: "Example Question"
    end

    scenario "Creating a new question also creates a display field" do
      survey = create :survey
      survey_version = survey.survey_versions.first
      login_user
      visit edit_survey_survey_version_path(survey, survey_version)
      add_text_question statement: "Example Question"
      visit survey_responses_path(survey_id: survey.id, survey_version_id: survey_version.id)
      click_link "Manage Display Fields", match: :first
      expect(page).to have_content "Example Question"
    end

    scenario "Creating a new question also creates a new rule" do
      survey = create :survey
      survey_version = survey.survey_versions.first
      login_user

      visit edit_survey_survey_version_path(survey, survey_version)
      add_text_question statement: "Example Question"
      visit survey_responses_path(survey_id: survey.id, survey_version_id: survey_version.id)
      click_link "Manage Rules", match: :first

      expect(page).to have_content "Example Question"
    end
  end

  context "choice question" do
    scenario "User adds a choice question with valid attributes" do
      survey = create :survey
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      add_choice_question statement: "Example Question", answer: "foo"
      expect(page).to have_css(".page_asset", text: "Example Question", count: 1)
    end

    scenario "User adds answer fields" do
      survey = create :survey
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      click_link "Add a multiple-choice question"
      expect(page).to have_css ".answer_fields input[type=text]", count: 4
      click_link "Add Answer"
      expect(page).to have_css ".answer_fields input[type=text]", count: 5
    end

    scenario "selecting flow control shows the target page dropdowns" do
      survey = create :survey
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      click_link "Add a multiple-choice question"
      check "Flow control"
      expect(page).to have_css ".next_pages", count: 4
    end

    scenario "User adds a choice question with invalid attributes" do
      survey = create :survey
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      add_choice_question statement: "", answer: "foo"
      expect(page).to_not have_css ".page_asset"
    end

    scenario "User deletes a choice question" do
      survey = create :survey
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      add_choice_question statement: "example", answer: "foo"
      within ".page_asset", text: "example" do
        click_link "Delete"
      end
      expect(page).to_not have_css ".page_asset", text: "example"
    end
  end

  context "matrix question" do
    scenario "User adds a matrix question with valid attributs" do
      survey = create :survey, :site
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      add_matrix_question statement: "Example QUestion",
        questions: ["Question 1"],
        answers: ["foo", "bar"]
      expect(page).to have_css ".page_asset"
    end

    scenario "User adds new question input fields" do
      survey = create :survey, :site
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      click_link "Add matrix question"
      expect(page).to have_css ".ChoiceQuestionContent input", count: 1
      click_link "Add Question"
      expect(page).to have_css ".ChoiceQuestionContent input", count: 2
    end

    scenario "User adds multiple questions to the matrix question" do
      survey = create :survey, :site
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      add_matrix_question statement: "Example Question",
        questions: ["Foo", "Bar"],
        answers: ["1", "2"]
      expect(page).to have_content "Foo"
      expect(page).to have_content "Bar"
    end

    scenario "User adds new answer fields to the matrix question" do
      survey = create :survey, :site
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      click_link "Add matrix question"
      expect(page).to have_css ".answer_fields input", count: 4
      click_link "Add Answer"
      expect(page).to have_css ".answer_fields input", count: 5
    end

    scenario "User adds an invalid matrix question" do
      survey = create :survey, :site
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      add_matrix_question statement: "",
        questions: ["Question 1"],
        answers: ["foo", "bar"]
      expect(page).to_not have_css ".page_asset"
    end

    scenario "User deletes a matrix question" do
      survey = create :survey, :site
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      add_matrix_question statement: "example",
        questions: ["foo"],
        answers: ["bar"]
      expect(page).to have_css ".page_asset", text: "example"
      within find(".page_asset", text: "example") do
        click_link "Delete"
      end
      expect(page).to_not have_css ".page_asset", text: "example"
    end
  end

  context "Add HTML Snippet" do
    scenario "with valid attributes" do
      survey = create :survey
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      click_link "Add snippet"
      fill_in "Snippet:", with: "<p>Example Snippet</p>"
      click_button "Create Snippet"
      expect(page).to have_css ".page_asset", text: "Example Snippet"
    end

    scenario "with invalid attributes" do
      survey = create :survey
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      click_link "Add snippet"
      fill_in "Snippet:", with: ""
      click_button "Create Snippet"
      expect(page).to_not have_css ".page_asset"
    end

    scenario "user deletes the HTML Snippet" do
      survey = create :survey
      login_user
      visit edit_survey_survey_version_path(survey, survey.survey_versions.first)
      click_link "Add snippet"
      fill_in "Snippet", with: "Test"
      click_button "Create Snippet"
      expect(page).to have_css ".page_asset", text: "Test"
      within find(".page_asset", text: "Test") do
        click_link "Delete"
      end
      expect(page).to_not have_css ".page_asset", text: "Test"
    end
  end

  def add_matrix_question statement:, questions:, answers:
    click_link "Add matrix question"
    fill_in "Statement:", with: statement
    question_inputs = page.all(:css, ".ChoiceQuestionContent textarea")
    if questions.size > question_inputs.count
      (questions.size - question_inputs.count).times do
        click_link "Add Question"
      end
      question_inputs = page.all(:css, ".ChoiceQuestionContent textarea")
    end
    answer_fields = page.all(:css, ".answer_fields input")
    if answers.size > answer_fields.count
      click_link "Add Answer"
      answer_fields = page.all(:css, ".answer_fields input")
    end

    question_inputs.zip(questions).each do |element, value|
      fill_in element[:name], with: value
    end
    answer_fields.zip(answers).each do |element, value|
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

  def add_text_question statement:
    click_link "Add an open-ended question"
    choose "Field"
    fill_in "Question:", with: statement
    click_button "Create Question"
  end
end
