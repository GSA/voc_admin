require "rails_helper"

RSpec.describe SurveysController, type: :controller do
  setup :activate_authlogic

  describe "GET /", "#index" do
    context "when a user is not logged in" do
      it "redirects to the login path" do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    context "when a user is logged in" do
      before(:each) do
        login_user
      end

      it "should render the index.html.erb template" do
        get :index
        expect(response).to render_template("index")
      end

      it "should assign @surveys" do
        get :index
        expect(assigns(:surveys)).to_not be_nil
      end

      it "should only list surveys for the sites of the logged in user" do
        other_site = FactoryGirl.create :site
        excluded_survey = FactoryGirl.create :survey, site: other_site
        included_survey = FactoryGirl.create :survey, site: @user.sites.first
        get :index
        expect(assigns(:surveys)).to_not include(excluded_survey)
        expect(assigns(:surveys)).to include(included_survey)
      end
    end

    context "when an admin user is logged in" do
      before(:each) { login_admin_user }
      it "should list all surveys" do
        get :index
        expect(assigns(:surveys).count).to eq Survey.count
      end
    end
  end

  def login_user
    @user = FactoryGirl.create :user, sites: [FactoryGirl.create(:site)]
    UserSession.create(@user, true)
  end

  def login_admin_user
    @admin_user = FactoryGirl.create :user, :admin
    UserSession.create(@admin_user, true)
  end
end
