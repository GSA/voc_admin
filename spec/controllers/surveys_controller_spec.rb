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
      let(:site) { FactoryGirl.create :site }
      let(:user) { FactoryGirl.create :user, sites: [site] }

      before(:each) do
        login_user(user)
      end

      it "should render the index.html.erb template" do
        get :index
        expect(response).to render_template("index")
      end

      it "should assign @surveys" do
        get :index
        expect(assigns(:surveys)).to_not be_nil
      end

      context "and search parameter is passed" do
        let!(:survey) { FactoryGirl.create :survey, name: "Found in search",
                        site: site }
        let!(:filtered_survey) {FactoryGirl.create :survey, 
                                name: "Should be filtered", site: site }

        it "should filter resultes based on the search" do
          get :index, q: "Found"
          expect(assigns(:surveys)).to include(survey)
          expect(assigns(:surveys)).to_not include(filtered_survey)
        end

        it "should preform a fuzzy search" do
          get :index, q: "in search"
          expect(assigns(:surveys)).to include(survey)
        end
      end

      context "and the user is not an admin" do
        it "should only list surveys for the sites of the logged in user" do
          excluded_survey = FactoryGirl.create :survey, 
            site: FactoryGirl.create(:site)
          included_survey = FactoryGirl.create :survey, site: site
          get :index
          expect(assigns(:surveys)).to_not include(excluded_survey)
          expect(assigns(:surveys)).to include(included_survey)
        end
      end

      context "and the user is an admin" do
        let(:admin_user) { FactoryGirl.create :user, :admin, f_name: "Admin" }
        before(:each) { login_user(admin_user) }
        it "should list all surveys" do
          survey = FactoryGirl.create :survey, site: site
          get :index
          expect(assigns(:surveys)).to include(survey)
        end
      end
    end

  end

  def login_user user = FactoryGirl.create(:user,
                                           sites: [FactoryGirl.create(:site)])
    UserSession.create(user, true)
  end

end
