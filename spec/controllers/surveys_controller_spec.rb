require "rails_helper"

RSpec.describe SurveysController, type: :controller do
  setup :activate_authlogic

  context "when a user is logged in" do
    let(:site) { FactoryGirl.create :site }
    let(:user) { FactoryGirl.create :user, sites: [site] }

    before(:each) do
      login_user(user)
    end

    describe "GET /", "#index" do
      it "should render the index.html.erb template" do
        get :index
        expect(response).to render_template("index")
      end

      it "should assign @surveys" do
        get :index
        expect(assigns(:surveys)).to_not be_nil
      end

      context "sorting" do
        let!(:first_survey) { FactoryGirl.create :survey, name: "A", site: site }
        let!(:second_survey) { FactoryGirl.create :survey, name: "B", site: site }

        it "should sort the surveys by name" do
          get :index
          surveys = assigns(:surveys)
          expect(surveys.first).to eq first_survey
          expect(surveys.last).to eq  second_survey
        end

        it "changes sort direction with the direction param" do
          get :index, direction: "desc"
          expect(assigns(:surveys)).to eq [second_survey, first_survey]
        end
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
    end # GET /

    describe "GET /new" do
      before(:each) { login_user }

      it "renders the new template" do
        get :new
        expect(response).to render_template("new")
      end

      it "assigns @survey" do
        get :new
        expect(assigns(:survey)).to be_a Survey
      end
    end # GET /new

    describe "POST /create" do
      context "with valid attributes" do
        let(:valid_attributes) { FactoryGirl.attributes_for(:survey, 
                                                            site_id: site.id) }
        it "saves the survey to the database" do
          expect {
            post :create, survey: valid_attributes
          }.to change(Survey, :count).by(1)
        end

        it "redirects to the survey version edit page" do
          post :create, survey: valid_attributes
          expect(response).to redirect_to(
            [:edit, assigns(:survey), assigns(:survey).survey_versions.first]
          )
        end
      end

      context "with invalid attributes" do
        let(:invalid_attributes) { attributes_for(:survey, name: nil) }
        it "does not save the survey to the database" do
          expect {
            post :create, survey: invalid_attributes
          }.to_not change(Survey, :count)
        end

        it "re-renders the :new template" do
          post :create, survey: invalid_attributes
          expect(response).to render_template("new")
        end
      end
    end # POST /create

    describe "GET /edit" do
      let(:survey) { create :survey, site: site }
      it "renders the edit template" do
        get :edit, id: survey.id
        expect(response).to render_template("edit")
      end

      it "assigns the @survey variable" do
        get :edit, id: survey.id
        expect(assigns(:survey)).to be_present
      end
    end # GET /edit

    describe "PUT /update" do
      let(:survey) { create :survey, site: site }
      context "with valid attributes" do
        it "locates the requested survey" do
          put :update, id: survey, survey: attributes_for(:survey)
          expect(assigns(:survey)).to eq survey
        end

        it "changes @survey's attributes" do
          put :update, id: survey, survey: attributes_for(:survey,
                                                          name: "updated")
          survey.reload
          expect(survey.name).to eq("updated")
        end

        it "redirects to the surveys index" do
          put :update, id: survey, survey: attributes_for(:survey)
          expect(response).to redirect_to surveys_path
        end
      end

      context "with invalid attributes" do
        it "does not change the survey's attributes" do
          put :update, id: survey, survey: attributes_for(:survey,
                                                          name: "updated",
                                                          description: nil)
          survey.reload
          expect(survey.name).not_to eq("updated")
        end

        it "re-renders the :edit template" do
          put :update, id: survey, survey: attributes_for(:survey, name: nil)
          expect(response).to render_template("edit")
        end
      end
    end
  end

  context "when a user is not logged in" do
    it "redirects to the login path" do
      get :index
      expect(response).to redirect_to login_path
    end
  end

  private
  def login_user user = FactoryGirl.create(:user,
                                           sites: [FactoryGirl.create(:site)])
    UserSession.create(user, true)
  end

end
