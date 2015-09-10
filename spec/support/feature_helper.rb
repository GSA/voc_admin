module FeatureHelper
  def login_user
    admin_user = create_admin_user
    visit login_path
    click_on "Jake Admin"
  end

  def create_admin_user
    user_attributes = {
      f_name: "John",
      l_name: "Doe",
      email: "jdoe@example.com",
      hhs_id: 2001149591,
      role_id: Role::ADMIN.id
    }

    User.find_by_hhs_id(user_attributes[:hhs_id]) || User.create!(user_attributes)
  end

  def create_test_site
    FactoryGirl.create(:site, name: "Test Site")
  end
end
