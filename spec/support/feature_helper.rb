module FeatureHelper
  ADMIN_HHS_ID = 2001149591
  def login_user
    create_admin_user
    visit login_path
    find(:xpath, "//a[@href='/login?user_id=#{ADMIN_HHS_ID}']").click
  end

  def create_admin_user
    User.find_by_hhs_id(ADMIN_HHS_ID) ||
      FactoryGirl.create(:user, :admin, hhs_id: ADMIN_HHS_ID)
  end

  def create_site
    visit sites_path
    first(:link, "New Site").click
    fill_in "Name:", with: "Test"
    fill_in "site_url", with: "http://test.com"
    fill_in "Description:", with: "Test Description"
    click_button "Create Site"
  end

  def create_survey
    add_execution_triggers
    visit root_path
    click_link "Create New Survey"
    fill_in "Name:", with: "Test Survey"
    fill_in "Description:", with: "Test Survey Description"
    select "Test", from: "survey_site_id"
    click_button "Create Survey"
  end

  def add_execution_triggers
    %w(add update delete nightly).each_with_index do |trigger, index|
      ExecutionTrigger.find_or_create_by_name(trigger) do |et|
        et.id = index + 1
      end
    end
  end
end
