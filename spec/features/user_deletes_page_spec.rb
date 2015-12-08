require "rails_helper"

RSpec.feature "User deletes page", js: true do
  scenario "page should be removed from the user's view" do
    setup_survey
    add_new_page

    find(:css, "div#page_2 .deleteLink").click
    expect(page).to have_css ".page", count: 1
  end

  scenario "user sees a message when tryign to delete a page targted by flow control" do
    setup_survey
    add_new_page

    click_link "Add a multiple-choice question", match: :first

    within "#simplemodal-container" do
      fill_in "Question:", with: "Test"
      fill_in "Answer:", with: "foo", match: :first
      click_button "Create Question"
    end

    save_and_open_page

    expect(page).to have_css ".page_asset", count: 1
  end

  def setup_survey
    login_user
    create_site
    create_survey
  end

  def create_site
    visit root_path
    click_link "Manage Sites"
    first(:link, "New Site").click
    fill_in "Name:", with: "Test"
    fill_in "site_url", with: "http://www.test.com"
    fill_in "Description:", with: "Test Site"
    click_button "Create Site"
  end

  def create_survey
    visit root_path
    click_link "Create New Survey"
    fill_in "Name:", with: "Example Survey"
    fill_in "Description:", with: "Example Survey Description"
    select Site.first.name, from: "survey_site_id"
    click_button "Create Survey"
    expect(page).to have_content "Edit Survey Version"
  end

  def add_new_page
    expect(page).to have_css ".page", count: 1
    click_link "Add New Page"
    expect(page).to have_css ".page", count: 2
  end
end
