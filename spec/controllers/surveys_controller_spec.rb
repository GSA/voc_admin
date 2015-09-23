require "rails_helper"

RSpec.describe SurveysController, type: :controller do
  setup :activate_authlogic

  context "when a user is logged in" do
    let(:site) { FactoryGirl.create :site }
    let(:user) { FactoryGirl.create :user, sites: [site] }
    let(:survey) { create :survey, site: site }

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
    end # PUT /update

    describe "DELETE /destroy" do
      before(:each) { survey }
      it "deletes the survey" do
        expect {
          delete :destroy, id: survey
        }.to change(Survey, :count).by(-1)
      end

      it "redirects to the surveys index" do
        delete :destroy, id: survey
        expect(response).to redirect_to(surveys_path)
      end

      it "sets the archived flag" do
        delete :destroy, id: survey
        survey.reload
        expect(survey.archived).to be true
      end
    end # DELETE /destroy

    describe "GET /start_page_preview" do
      it "sets @survey" do
        get :start_page_preview, id: survey
        expect(assigns(:survey)).to eq survey
      end

      it "renders the :start_page_preview template" do
        get :start_page_preview, id: survey
        expect(response).to render_template(:start_page_preview)
      end

      it "does not render the application layout template" do
        get :start_page_preview, id: survey
        expect(response).to_not render_template(layout: "application")
      end
    end # GET /start_page_preview

    describe "GET /all_questions" do
      context "when logged in as admin" do
        before(:each) do
          login_user FactoryGirl.create(:user, :admin, sites: [site])
        end

        context "with no published versions" do
          it "sets @published_versions to an empty array" do
            get :all_questions
            expect(assigns(:published_versions)).to be_empty
          end
        end

        context "with some published and some unpublished versions" do
          it "should set @published_versions to an array of only published versions" do
            published_version = survey.survey_versions.first
            published_version.publish_me
            get :all_questions
            expect(assigns(:published_versions)).to eq [published_version]
          end

          it "does not include unpublished versions" do
            unpublished_version = survey.survey_versions.first
            get :all_questions
            expect(assigns(:published_versions)).to_not include(unpublished_version)
          end
        end
      end

      context "when not logged in as an admin" do
        it "redirects to the surveys index" do
          get :all_questions
          expect(response).to redirect_to(surveys_path)
        end
      end
    end # GET /all_questions

    describe "POST /import_survey_version" do
      it "assigns @survey" do
        post :import_survey_version, survey_id: survey
        expect(assigns(:survey)).to eq survey
      end
      context "with params[:file]" do
        it "calls import_survey_version on @survey" do
          survey = instance_spy(Survey)
          allow(Survey).to receive(:find) { 1 }.and_return survey
          file = fixture_file_upload("/survey_export.json", "application/json")
          expect(survey).to receive(:import_survey_version)
          post :import_survey_version, survey_id: 1, file: file
        end
      end

      context "without params[:file]" do
        it "redirects to survey_versions list" do
          post :import_survey_version, survey_id: survey
          expect(response).to redirect_to(survey_survey_versions_path(survey))
        end
      end
    end # POST /import_survey_version
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
