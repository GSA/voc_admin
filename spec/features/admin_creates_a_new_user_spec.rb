require "rails_helper"

RSpec.feature "Admin creates a new user" do
  scenario "with valid attributes" do
    login_user
    click_link "Manage Users"
    submit_user first_name: "Example", last_name: "User", email: "example@test.com",
      hhs_id: "0123456789", role: "Admin"
    expect(page).to have_content "Example User"
  end

  scenario "with invalid attributes" do
    login_user
    click_link "Manage Users"
    submit_user first_name: "Example", last_name: "User", email: "example@test.com",
      hhs_id: "", role: "Admin"
    expect(page).to_not have_content "Example User"
  end


  def submit_user first_name:, last_name:, email:, hhs_id:, role:
    click_link "New User", match: :first
    fill_in "First Name", with: first_name
    fill_in "Last Name", with: last_name
    fill_in "Email", with: email
    fill_in "HHS ID", with: hhs_id
    choose role
    click_button "Create User"
  end
end
