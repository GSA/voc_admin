require "rails_helper"

RSpec.feature "Admin creates a new user" do
  scenario "with valid attributes" do
    login_user
    click_link "Manage Users"
    submit_user first_name: "Example", last_name: "User", email: "example@test.com",
      hhs_id: "0123456789", role: "Admin"
    expect(page).to have_content "Example User"
  end

  scenario "without the admin role" do
    login_user
    click_link "Manage Users"
    submit_user first_name: "Example", last_name: "User", email: "example@test.com",
      hhs_id: "0123456789", role: "User", sites: [create(:site).name]
    expect(page).to have_content "Example User"
  end

  scenario "with invalid attributes" do
    login_user
    click_link "Manage Users"
    submit_user first_name: "Example", last_name: "User", email: "example@test.com",
      hhs_id: "", role: "Admin"
    expect(page).to_not have_content "Example User"
    expect(page).to have_content "can't be blank"
  end


  def submit_user first_name:, last_name:, email:, hhs_id:, role:, sites: []
    click_link "New User", match: :first
    fill_in "First Name", with: first_name
    fill_in "Last Name", with: last_name
    fill_in "Email", with: email
    fill_in "HHS ID", with: hhs_id
    choose role
    if role == "User"
      sites.each do |site|
        select site, from: "Sites"
      end
    end
    click_button "Create User"
  end
end
