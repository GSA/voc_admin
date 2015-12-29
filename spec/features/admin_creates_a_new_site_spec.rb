require "rails_helper"

RSpec.feature "Admin creates a new site", js: true do
  scenario "with valid attributes" do
    login_user
    visit root_path
    click_link "Manage Sites"
    click_link "New Site", match: :first
    fill_in "Name", with: "Example Site"
    fill_in "site_url", with: "http://test.com"
    fill_in "Description", with: "RSpec feature test created site"
    click_button "Create Site"
    expect(page).to have_css "#flash_notice", text: "Successfully created new site."
  end

  scenario "with invalid attributes" do
    login_user
    visit root_path
    click_link "Manage Sites"
    click_link "New Site", match: :first
    fill_in "Name", with: "Example Site"
    fill_in "Description", with: "RSpec feature test created site"
    fill_in "site_url", with: ""
    click_button "Create Site"
    expect(page).to have_content "can't be blank"
  end
end
