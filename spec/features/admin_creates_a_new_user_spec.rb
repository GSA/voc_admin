require "rails_helper"

RSpec.feature "Admin creates a new user" do
  scenario "with valid attributes" do
    login_user
    click_link "Manage Users"
    submit_user first_name: "Example", last_name: "User",
      email: "example@test.com", role: "Admin", username: "euser"
    expect(page).to have_content "Example User"
  end

  scenario "without the admin role" do
    login_user
    click_link "Manage Users"
    submit_user first_name: "Example", last_name: "User", email: "example@test.com",
      role: "User", sites: [create(:site).name], username: "euser"
    expect(page).to have_content "Example User"
  end

  scenario "with invalid attributes" do
    login_user
    click_link "Manage Users"
    submit_user first_name: "Example", last_name: "User", email: "example@test.com",
      role: "Admin", username: ""
    expect(page).to_not have_content "Example User"
    expect(page).to have_content "can't be blank"
  end


  def submit_user first_name:, last_name:, email:, username:, role:, sites: []
    click_link "New User", match: :first
    fill_in "First Name", with: first_name
    fill_in "Last Name", with: last_name
    fill_in "Username", with: username
    fill_in "Email", with: email
    choose role
    if role == "User"
      sites.each do |site|
        select site, from: "Sites"
      end
    end
    click_button "Create User"
  end
end
