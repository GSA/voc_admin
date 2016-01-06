require "rails_helper"

RSpec.feature "User creates a new rule", js: true do
  scenario "with valid attributes" do
    create_test_survey_with_text_question statement: "Text Question"
    Conditional.create! name: "="

    add_rule name: "Custom Rule", action: "Database Action", trigger: "Add",
      criteria: [{ source: "Text Question(Question)", conditional: "=", value: "Test" }],
      actions: [{update: "Text Question", value: "Test"}]


    expect(page).to have_content "Custom Rule"
  end

  scenario "with multiple criteria" do
    create_test_survey_with_text_question statement: "Text Question"
    Conditional.create! name: "="
    Conditional.create! name: ">"

    add_rule name: "Custom Rule", action: "Database Action", trigger: "Add",
      criteria: [
        {source: "Text Question(Question)", conditional: "=", value: "Test"},
        {source: "Text Question(Question)", conditional: ">", value: "Test"}
      ],
      actions: [{update: "Text Question", value: "Test"}]

    expect(page).to have_css(".criteria li", text: "Test", count: 2)
  end

  scenario "with multiple actions" do
    create_test_survey_with_text_question statement: "Text Question"
    Conditional.create! name: "="

    add_rule name: "Custom Rule", action: "Database Action", trigger: "Add",
      criteria: [
        {source: "Text Question(Question)", conditional: "=", value: "Test"}
      ],
      actions: [
        {update: "Text Question", value: "Test"},
        {update: "Text Question", value: "Foo"}
      ]

    expect(page).to have_css ".actions li", count: 2
  end

  scenario "with invalid attributes" do
    create_test_survey_with_text_question statement: "Text Question"
    Conditional.create! name: "="

    add_rule name: "", action: "Database Action", trigger: "Add",
      criteria: [{ source: "Text Question(Question)", conditional: "=", value: "Test" }],
      actions: [{update: "Text Question", value: "Test"}]

    expect(page).to have_content "can't be blank"
  end

  def create_test_survey_with_text_question statement:
    login_user
    create_site
    survey = setup_survey name: "Example"
    load_responses_for survey_name: "Example", version_number: "1.0"
    add_text_question survey_version: survey.survey_versions.first,
      statement: statement
  end

  def add_text_question survey_version:, statement:
    FactoryGirl.create(:text_question,
      survey_version: survey_version,
      question_content: FactoryGirl.create(:question_content, statement: statement)
    )
  end

  def add_rule name:, action:, trigger:, criteria:, actions:
    click_link "Manage Rules", match: :first
    click_link "Add New Rule", match: :first
    fill_in "Name", with: name
    choose action
    check trigger

    # Build the criteria objects
    if criteria.size > 1
      (criteria.size-1).times { click_link("Add Criteria") }
    end
    criteria.zip(page.all(:css, ".criterion")) do |criterion, fields|
      within fields do
        select criterion.fetch(:source), from: "Source select"
        select criterion.fetch(:conditional), from: "Conditional"
        fill_in "Value", with: criterion.fetch(:value)
      end
    end

    # Build the action objects
    if actions.size > 1
      (actions.size-1).times { click_link("Add Action") }
    end
    actions.zip(page.all(:css, ".db_action")) do |action, fields|
      within fields do
        select action.fetch(:update), from: "Update"
        fill_in "value_text", with: action.fetch(:value)
      end
    end

    click_button "Create Rule"
  end
end
