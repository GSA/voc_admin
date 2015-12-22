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

  def login_user user:
    UserSession.find.try(:destroy)
    UserSession.create user, false
  end
end
