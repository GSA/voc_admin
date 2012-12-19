require 'spec_helper'

describe AssetsController do
  include Authlogic::TestCase

  let(:site) { create :site }
  let(:survey) { create :survey, { site: site } }
  let(:survey_version) { create :survey_version, { survey: survey } }
  let(:asset) { mock_model(Asset) }

  before do
    activate_authlogic
    user = User.create(email: "email@example.com", password: "password", password_confirmation: "password", f_name: "example", l_name: "user")
    user.sites << site
    UserSession.create user

    User.any_instance.stub_chain(:surveys, :find).and_return(survey)
    Survey.any_instance.stub_chain(:survey_versions, :find).and_return(survey_version)
  end

  context 'new' do
    it 'should build a new Asset' do
      survey_version.assets.should_receive(:build)

      get :new, survey_id: survey.id, survey_version_id: survey_version.id
    end

    it 'should render new' do
      survey_version.stub_chain(:assets, :build)

      get :new, survey_id: survey.id, survey_version_id: survey_version.id

      response.should render_template(:new)
    end

    it 'should render new.js' do
      survey_version.stub_chain(:assets, :build)

      get :new, survey_id: survey.id, survey_version_id: survey_version.id, format: :js

      response.should render_template(:new)
    end
  end

  context 'create' do
    it 'should create a new Asset' do
      asset.stub_chain(:survey_element, :survey_version_id=)
      asset.stub(:save).and_return true

      Asset.should_receive(:new).and_return(asset)

      post :create, survey_id: survey.id, survey_version_id: survey_version.id
    end

    it 'should assign survey_version_id to SurveyElement of Asset' do
      Asset.stub(:new).and_return(asset)
      asset.stub(:save).and_return true

      survey_element_double = double
      asset.stub(:survey_element).and_return(survey_element_double)
      survey_element_double.should_receive(:survey_version_id=)

      post :create, survey_id: survey.id, survey_version_id: survey_version.id
    end

    it 'should render new if validation fails' do
      Asset.stub(:new).and_return(asset)
      asset.stub_chain(:survey_element, :survey_version_id=)
      asset.stub(:save).and_return false

      post :create, survey_id: survey.id, survey_version_id: survey_version.id

      response.should render_template(:new)
    end

    it 'should redirect to show survey with message' do
      Asset.stub(:new).and_return(asset)
      asset.stub_chain(:survey_element, :survey_version_id=)
      asset.stub(:save).and_return true

      post :create, survey_id: survey.id, survey_version_id: survey_version.id

      response.should redirect_to(survey_path survey)
      flash[:notice].should =~ /Successfully added HTML snippet./i
    end

    it 'should render element_create.js' do
      Asset.stub(:new).and_return(asset)
      asset.stub_chain(:survey_element, :survey_version_id=)
      asset.stub(:save)

      post :create, survey_id: survey.id, survey_version_id: survey_version.id, format: :js

      response.should render_template('shared/_element_create')
    end
  end

  context 'edit' do
    it 'should ask the SurveyVersion for the appropriate Asset' do
      assets_double = double
      survey_version.stub(:assets).and_return(assets_double)

      assets_double.should_receive(:find)

      get :edit, survey_id: survey.id, survey_version_id: survey_version.id, id: asset.id
    end

    it 'should render edit' do
      survey_version.stub_chain(:assets, :find)

      get :edit, survey_id: survey.id, survey_version_id: survey_version.id, id: asset.id

      response.should render_template(:edit)
    end

    it 'should render edit.js' do
      survey_version.stub_chain(:assets, :find)

      get :edit, survey_id: survey.id, survey_version_id: survey_version.id, id: asset.id, format: :js

      response.should render_template(:edit)
    end
  end

  context 'update' do
    before(:each) do
      Asset.stub(:find).and_return(asset)
    end

    it 'should render edit if validation fails' do
      asset.stub(:update_attributes).and_return false

      put :update, survey_id: survey.id, survey_version_id: survey_version.id, id: asset.id

      response.should render_template(:edit)
    end

    it 'should redirect to show survey with message' do
      asset.stub(:update_attributes).and_return true

      put :update, survey_id: survey.id, survey_version_id: survey_version.id, id: asset.id

      response.should redirect_to(survey_path survey)
      flash[:notice].should =~ /Successfully updated HTML snippet./i
    end

    it 'should render element_create.js' do
      asset.stub(:update_attributes)

      put :update, survey_id: survey.id, survey_version_id: survey_version.id, id: asset.id, format: :js

      response.should render_template('shared/_element_create')
    end
  end

  context 'destroy' do
    it 'should call for destruction of the Asset' do
      assets_double = double
      survey_version.stub(:assets).and_return(assets_double)

      assets_double.stub(:find).and_return(asset)
      asset.should_receive(:destroy)

      delete :destroy, survey_id: survey.id, survey_version_id: survey_version.id, id: asset.id
    end

    it 'should redirect to show survey with message' do
      survey_version.stub_chain(:assets, :find).and_return(asset)
      asset.stub(:destroy)

      delete :destroy, survey_id: survey.id, survey_version_id: survey_version.id, id: asset.id

      response.should redirect_to(survey_path survey)
      flash[:notice].should =~ /Successfully deleted HTML snippet./i
    end

    it 'should render element_destroy.js' do
      survey_version.stub_chain(:assets, :find).and_return(asset)
      asset.stub(:destroy)

      delete :destroy, survey_id: survey.id, survey_version_id: survey_version.id, id: asset.id, format: :js

      response.should render_template('shared/_element_destroy')
    end
  end
end
