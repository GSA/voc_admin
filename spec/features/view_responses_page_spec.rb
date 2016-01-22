require "rails_helper"

RSpec.feature "View Responses Page", js: true do
  it "Updates the version select dropdown when a survey is selected" do
    login_user
    create_site
    setup_survey name: "Test Site"
    visit survey_responses_path
    expect(page).to_not have_select "survey_version_id", with_options: ["1.0"]

    select "Test Site", from: "survey_id"

    expect(page).to have_select "survey_version_id", with_options: ["1.0"]
  end

  it "Updates the responses table when a version is selected" do
    login_user
    create_site
    setup_survey name: "Example"

    load_responses_for survey_name: "Example", version_number: "1.0"

    expect(page).to have_css "#survey_response_table_div table"
  end

  it "Shows the submitted responses to the survey" do
    login_user
    create_site
    survey = setup_survey name: "Example"
    survey_version = survey.survey_versions.first
    question = add_text_question statement: "Text Question",
      survey_version: survey_version
    response_params = {
      "page_url" => "http://example.com",
      "device" => "Desktop",
      "raw_responses_attributes" => {
        "0" => {
          "question_content_id" => question.question_content.id.to_s,
          "answer" => "Test Answer"
        }
      }
    }
    SurveyResponse.process_response response_params, survey_version.id
    sleep 1 # Give elasticsearch time to index the response
    load_responses_for survey_name: "Example", version_number: "1.0"

    visit survey_responses_path(survey_id: survey.id, survey_version_id: survey_version.id)
    expect(page).to have_content "Test Answer"
  end

  context "clicking on the Advanced Search link" do
    it "Shows the advanced search fields if not already shown" do
      login_user
      create_site
      setup_survey name: "Example"
      load_responses_for survey_name: "Example", version_number: "1.0"
      expect(page).to_not have_css "div#advanced_search"

      click_link "Advanced Search"

      expect(page).to have_css "div#advanced_search"
    end

    it "Hides the advanced search fields if it is already showing" do
      login_user
      create_site
      setup_survey name: "Example"
      load_responses_for survey_name: "Example", version_number: "1.0"
      click_link "Advanced Search"
      expect(page).to have_css "div#advanced_search"

      click_link "Advanced Search"

      expect(page).to_not have_css "div#advanced_search"
    end
  end
end
