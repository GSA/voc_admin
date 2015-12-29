require "rails_helper"

RSpec.describe SurveysController, type: :controller do
  setup :activate_authlogic

  context "GET /", "#index" do
    let(:site) { FactoryGirl.create :site }
    it "should render the index template" do
      login_user user: FactoryGirl.create(:user)
      get :index
      expect(response).to render_template("index")
    end

    it "should assign @surveys" do
      login_user user: FactoryGirl.create(:user)
      get :index
      expect(assigns(:surveys)).to_not be_nil
    end

    it "should only return surveys for sites the user has access to" do
      login_user user: FactoryGirl.create(:user, site_ids: [site.id], role_id: nil)
      FactoryGirl.create :survey, name: "included survey", site: site
      FactoryGirl.create :survey, name: "should not be visible"
      get :index
      expect(assigns(:surveys).map(&:name)).to eq ["included survey"]
    end

    it "sorts the surveys by name" do
      login_user user: FactoryGirl.create(:user, site_ids: [site.id])
      FactoryGirl.create :survey, name: "C", description: "last", site: site
      FactoryGirl.create :survey, name: "A", description: "first", site: site
      FactoryGirl.create :survey, name: "B", description: "middle", site: site
      get :index
      expect(assigns(:surveys).map(&:description)).to eq %w(first middle last)
    end

    context "when passed the direction parameter" do
      it "changes the sort direction" do
        login_user user: FactoryGirl.create(:user, site_ids: [site.id])
        FactoryGirl.create :survey, name: "A", description: "last", site: site
        FactoryGirl.create :survey, name: "B", description: "middle", site: site
        FactoryGirl.create :survey, name: "C", description: "first", site: site
        get :index, direction: "desc"
        expect(assigns(:surveys).map(&:description)).to eq %w(first middle last)
      end
    end

    context "when passed the q parameter" do
      it "filters results based on q" do
        login_user user: FactoryGirl.create(:user, site_ids: [site.id])
        FactoryGirl.create :survey, name: "Included", site: site
        FactoryGirl.create :survey, name: "Excluded", site: site
        get :index, q: "nclude"
        expect(assigns(:surveys).map(&:name)).to eq ["Included"]
      end
    end

    context "when logged in as an admin" do
      it "should list all surveys regardless of site" do
        login_user user: FactoryGirl.create(:user, :admin)
        FactoryGirl.create_list :survey, 3
        get :index
        expect(assigns(:surveys).count).to eq 3
      end
    end
  end

  context "GET /new", "#new" do
    it "renders the new template" do
      login_user user: FactoryGirl.create(:user)
      get :new
      expect(response).to render_template("new")
    end

    it "assigns @survey" do
      login_user user: FactoryGirl.create(:user)
      get :new
      expect(assigns(:survey)).to be_a Survey
    end
  end

  context "POST /create", "#create" do
    context "with valid attributes" do
      let(:valid_attributes) { FactoryGirl.attributes_for :survey, site_id: FactoryGirl.create(:site).id }
      it "saves the survey to the database" do
        login_user user: FactoryGirl.create(:user)
        expect {
          post :create, survey: valid_attributes
        }.to change(Survey, :count).by(1)
      end

      it "redirects to the survey version edit page" do
        login_user user: FactoryGirl.create(:user)
        post :create, survey: valid_attributes
        expect(response).to redirect_to [:edit, assigns(:survey), assigns(:survey).survey_versions.first]
      end
    end

    context "with invalid attributes" do
      it "does not save the survey to the database" do
        invalid_attributes = FactoryGirl.attributes_for :survey, name: nil
        login_user user: FactoryGirl.create(:user)
        expect { post :create, survey: invalid_attributes }.to_not change{Survey.count}
      end

      it "re-renders the :new template" do
        invalid_attributes = FactoryGirl.attributes_for :survey, name: nil
        login_user user: FactoryGirl.create(:user)
        post :create, survey: invalid_attributes
        expect(response).to render_template("new")
      end
    end
  end

  context "GET /edit", "#edit" do
    it "renders the edit template" do
      site = FactoryGirl.create(:site)
      survey = FactoryGirl.create(:survey, site_id: site.id)
      login_user user: FactoryGirl.create(:user, site_ids: [site.id])
      get :edit, id: survey.id
      expect(response).to render_template("edit")
    end

    it "assigns the @survey variable" do
      site = FactoryGirl.create(:site)
      survey = FactoryGirl.create(:survey, site_id: site.id)
      login_user user: FactoryGirl.create(:user, site_ids: [site.id])
      get :edit, id: survey.id
      expect(assigns(:survey)).to be_a(Survey)
    end
  end

  context "PATCH /update", "#update" do
    it "assigns @survey" do
      site = FactoryGirl.create :site
      survey = FactoryGirl.create :survey, site_id: site.id
      login_user user:FactoryGirl.create(:user, site_ids: [site.id])
      patch :update, id: survey.id
      expect(assigns(:survey)).to be_a(Survey)
    end

    context "with valid attributes" do
      it "updates the survey in the database" do
        site = FactoryGirl.create :site
        survey = FactoryGirl.create :survey, site_id: site.id
        valid_attributes = { name: "updated" }
        login_user user: FactoryGirl.create(:user, site_ids: [site.id])
        expect { patch :update, id: survey.id, survey: valid_attributes }
          .to change { Survey.find(survey.id).name }
      end
      it "redirects to the surveys index" do
        site = FactoryGirl.create :site
        survey = FactoryGirl.create :survey, site_id: site.id
        valid_attributes = { name: "updated" }
        login_user user: FactoryGirl.create(:user, site_ids: [site.id])
        patch :update, id: survey.id, survey: valid_attributes
        expect(response).to redirect_to surveys_path
      end
    end

    context "with invalid attributes" do
      it "does not update the survey in the database" do
        site = FactoryGirl.create :site
        survey = FactoryGirl.create :survey, site_id: site.id
        invalid_attributes = { name: "" }
        login_user user: FactoryGirl.create(:user, site_ids: [site.id])
        expect { patch :update, id: survey.id, survey: invalid_attributes }
          .to_not change { Survey.find(survey.id).name }
      end
      it "renders the edit template" do
        site = FactoryGirl.create :site
        survey = FactoryGirl.create :survey, site_id: site.id
        invalid_attributes = { name: "" }
        login_user user: FactoryGirl.create(:user, site_ids: [site.id])
        patch :update, id: survey.id, survey: invalid_attributes
        expect(response).to render_template("edit")
      end
    end
  end

  context "DELETE /destroy", "#destroy" do
    it "sets the archived flag for the survey" do
      survey = FactoryGirl.create :survey
      login_user user: FactoryGirl.create(:user, site_ids: [survey.site_id])
      delete :destroy, id: survey.id
      survey.reload
      expect(survey.archived).to be true
      expect(response).to redirect_to surveys_path
    end
  end

  context "GET /start_page_preview", "#start_page_preview" do
    it "assigns @survey" do
      survey = FactoryGirl.create :survey
      login_user user: FactoryGirl.create(:user, site_ids: [survey.site_id])
      get :start_page_preview, id: survey.id
      expect(assigns(:survey)).to be_a Survey
    end
    it "renders the start_page_preview template" do
      survey = FactoryGirl.create :survey
      login_user user: FactoryGirl.create(:user, site_ids: [survey.site_id])
      get :start_page_preview, id: survey.id
      expect(response).to render_template("start_page_preview")
      expect(response).to_not render_template(layout: "application")
    end
  end

  context "GET /all_questions", "#all_questions" do
    it "redirects to the surveys index when user is not an admin" do
      expect(Role::ADMIN).to_not be_nil
      login_user user: FactoryGirl.create(:user)
      get :all_questions
      expect(response).to redirect_to surveys_path
    end
    it "shows only published versions" do
      expect(Role::ADMIN.id).to_not be_nil
      published_version = FactoryGirl.create :survey_version, :published
      login_user user: FactoryGirl.create(:user, role_id: Role::ADMIN.id)
      get :all_questions
      expect(assigns(:current_user).admin?).to be true
      expect(assigns(:published_versions)).to eq [published_version]
      expect(response).to render_template("all_questions")
    end
  end

  context "POST /import_survey_version", "#import_survey_version" do
    it "assigns @survey" do
      survey = FactoryGirl.create :survey
      login_user user: FactoryGirl.create(:user, site_ids: [survey.site_id])
      post :import_survey_version, survey_id: survey.id
      expect(assigns(:survey)).to eq survey
    end

    context "with valid import" do
      it "calls import_survey_version on survey" do
        survey = instance_spy(Survey)
        allow(Survey).to receive(:find) {1}.and_return survey
        file = fixture_file_upload("/survey_export.json", "application/json")
        login_user user: FactoryGirl.create(:user)
        expect(survey).to receive(:import_survey_version)
        post :import_survey_version, survey_id: 1, file: file
      end
    end

    context "with invalid import" do
      it "redirects to the survey_versions list" do
        survey = double(Survey)
        allow(Survey).to receive(:find) {1}.and_return survey
        login_user user: FactoryGirl.create(:user)
        post :import_survey_version, survey_id: 1
        expect(response).to redirect_to survey_survey_versions_path(survey)
      end
      it "sets an error message" do
        survey = double(Survey)
        allow(Survey).to receive(:find) {1}.and_return survey
        login_user user: FactoryGirl.create(:user)
        post :import_survey_version, survey_id: 1
        expect(flash[:alert]).to eq "Please select a file before clicking the import button."
      end
    end
  end

  def login_user user:
    UserSession.create user, false
    expect(UserSession.find.user).to eq user
  end
end
