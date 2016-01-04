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

  def setup_survey name:, site: FactoryGirl.create(:site),
    survey_type: FactoryGirl.create(:survey_type)
    FactoryGirl.create(:survey,
                       name: name,
                       site: site,
                       survey_type: survey_type
                      )
  end

  def load_responses_for survey_name:, version_number:
    visit survey_responses_path
    select survey_name, from: "survey_id"
    select version_number, from: "survey_version_id"
  end
end
