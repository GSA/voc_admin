require "rails_helper"

feature "User login" do
  scenario "user is redirected to the homepage" do
    login_user
    visit root_path
    expect(current_path).to eq surveys_path
    expect(page).to have_selector("h1", text: "All Surveys")
  end
end

