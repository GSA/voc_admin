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
end
