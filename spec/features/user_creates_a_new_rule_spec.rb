require "rails_helper"

RSpec.feature "User creates a new rule", js: true do
  scenario "with valid attributes" do
    create_test_survey_with_text_question statement: "Text Question"
    Conditional.create! name: "="

    add_rule name: "Custom Rule", action: "Database Action", trigger: "Add",
      criteria: [{ source: "Text Question(Question)", conditional: "=", value: "Test" }],
      actions: [{update: "Text Question", value: "Test"}]

    expect(page).to have_content "Custom Rule"
    expect(page).to have_content "Successfully created rule."
  end

  context "with 'Email Action' rule type" do
    scenario "shows the email action fields" do
      create_test_survey_with_text_question statement: "Text Question"

      click_link "Manage Rules", match: :first
      click_link "Add New Rule", match: :first
      choose "Email Notification"

      expect(page).to have_css "div#email_action"
      expect(page).to_not have_css "div#db_actions"
    end

    scenario "and valid attributes" do
      create_test_survey_with_text_question statement: "Text Question"
      Conditional.create! name: "="

      add_rule name: "Custom Rule", action: "Email Notification", trigger: "Add",
        criteria: [
          { source: "Text Question(Question)", conditional: "=", value: "Test" }
        ],
        actions: [{to: "test@example.com", subject: "Test", body: "Test"}]

      expect(page).to have_content "Custom Rule"
      expect(page).to have_content "Successfully created rule."
    end

    scenario "and invalid action attributes" do
      create_test_survey_with_text_question statement: "Text Question"
      Conditional.create! name: "="

      add_rule name: "Custom Rule", action: "Email Notification", trigger: "Add",
        criteria: [
          { source: "Text Question(Question)", conditional: "=", value: "Test" }
        ],
        actions: [{to: "", subject: "Test", body: "Test"}]

      expect(page).to have_content "can't be blank"
      expect(page).to_not have_content "Successfully created rule."
    end
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
    if action == "Database Action"
      if actions.size > 1
        (actions.size-1).times { click_link("Add Action") }
      end
      actions.zip(page.all(:css, ".db_action")) do |action, fields|
        within fields do
          select action.fetch(:update), from: "Update"
          fill_in "value_text", with: action.fetch(:value)
        end
      end
    elsif action == "Email Notification"
      within "#actions" do
        fill_in "Send email to", with: actions.first.fetch(:to)
        fill_in "Subject Line", with: actions.first.fetch(:subject)
        fill_in "Message Content", with: actions.first.fetch(:body)
      end
    end

    click_button "Create Rule"
  end
end
