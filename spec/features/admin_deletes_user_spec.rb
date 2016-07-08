require "rails_helper"

RSpec.feature "Admin deletes user" do
  scenario "it should remove the user from the user table" do
    create(:user, f_name: "Example", l_name: "User")
    login_user
    click_link "Manage Users"
    expect(page).to have_content "Example User"
    within find('tr', text: "Example User") do
      click_link("delete") # finds the delete link using the image alt text
    end
    expect(page).to_not have_content "Example User"
  end
end
