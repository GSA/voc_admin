require 'spec_helper'

describe SurveyVersionsController do
  include Authlogic::TestCase

  let(:site) { create :site }
  let(:survey) { create :survey, { site: site } }
  let(:survey_version) { create :survey_version, { survey: survey } }

  before do
    activate_authlogic
    user = User.create(email: 'email@example.com', password: 'password', password_confirmation: 'password', f_name: 'example', l_name: 'user')
    user.sites << site
    UserSession.create user

    User.any_instance.stub_chain(:surveys, :find).and_return(survey)
    Survey.any_instance.stub_chain(:survey_versions, :find).and_return(survey_version)
  end

  context 'publish' do
    it 'should redirect to index with error if there are no questions' do
      survey_version.stub_chain(:questions, :empty?).and_return true

      get :publish, survey_id: survey.id, id: survey_version.id

      response.should redirect_to(survey_survey_versions_path survey)
      flash[:error].should =~ /Cannot publish an empty survey./i
    end

    context 'when there are questions' do
      before(:each) do
        survey_version.stub_chain(:questions, :empty?).and_return false
      end

      it 'should redirect to index with message' do
        survey_version.stub(:publish_me)
        Rails.stub_chain(:cache, :clear)

        get :publish, survey_id: survey.id, id: survey_version.id

        response.should redirect_to(survey_survey_versions_path survey)
        flash[:notice].should =~ /Successfully published survey version./i
      end

      it 'should publish the survey version' do
        Rails.stub_chain(:cache, :clear)

        survey_version.should_receive(:publish_me)

        get :publish, survey_id: survey.id, id: survey_version.id
      end

      it 'should clear the Rails cache' do
        survey_version.stub(:publish_me)

        Rails.cache.should_receive(:clear).once

        get :publish, survey_id: survey.id, id: survey_version.id
      end
    end
  end

  context 'unpublish' do
    it 'should redirect to index with message' do
      get :unpublish, survey_id: survey.id, id: survey_version.id

      response.should redirect_to(survey_survey_versions_path survey)
      flash[:notice].should =~ /Successfully unpublished survey version/i
    end

    it 'should unpublish the survey' do
      survey_version.should_receive(:unpublish_me)

      get :unpublish, survey_id: survey.id, id: survey_version.id
    end
  end

  context 'clone version' do
    it 'should clone the survey version' do
      survey_version.should_receive(:clone_me)

      get :clone_version, survey_id: survey.id, id: survey_version.id
    end

    it 'should redirect to index with message' do
      survey_version.stub(:clone_me)

      get :clone_version, survey_id: survey.id, id: survey_version.id

      response.should redirect_to(survey_survey_versions_path survey)
      flash[:notice].should =~ /Successfully cloned new minor version/i
    end
  end

  context 'edit thank you page' do
    it 'should render the edit thank you page template' do
      get :edit_thank_you_page, survey_id: survey.id, id: survey_version.id

      response.should render_template(:edit_thank_you_page)
    end
  end

  context 'update thank you page' do
    it 'should render edit if update_attributes fails' do
      survey_version.stub(:update_attributes).and_return(false)

      put :update, survey_id: survey.id, id: survey_version.id, survey_version: { thank_you_page: 'test contents' }

      response.should render_template(:edit)
    end

    it 'should redirect to index with message' do
      survey_version.stub(:update_attributes).and_return(true)

      put :update, survey_id: survey.id, id: survey_version.id, survey_version: { thank_you_page: 'test contents' }

      response.should redirect_to(survey_survey_versions_path survey)
      flash[:notice].should =~ /Successfully updated the thank you page/i
    end
  end

  context 'create new major version' do
    it 'should create a new major version' do
      survey.should_receive(:create_new_major_version)

      get :create_new_major_version, survey_id: survey.id
    end

    it 'should redirect to index with message' do
      survey.stub(:create_new_major_version)

      get :create_new_major_version, survey_id: survey.id

      response.should redirect_to(survey_survey_versions_path survey)
      flash[:notice].should =~ /Major Survey Version was successfully created./i
    end
  end

  context 'index' do
    it 'should render the index template' do
      survey.stub_chain(:survey_versions, :get_unarchived, :order, :page, :per).and_return survey

      get :index, survey_id: survey.id

      response.should render_template(:index)
    end
  end

  context 'edit' do
    it 'should redirect to /surveys if survey archived' do
      survey.stub(:archived).and_return true
      survey_version.stub(:archived).and_return false

      get :edit, survey_id: survey.id, id: survey_version.id

      response.should redirect_to(surveys_path)
      flash[:notice].should =~ /The survey you are trying to access has been removed/i
    end

    it 'should redirect to /surveys if survey version archived' do
      survey.stub(:archived).and_return false
      survey_version.stub(:archived).and_return true

      get :edit, survey_id: survey.id, id: survey_version.id

      response.should redirect_to(surveys_path)
      flash[:notice].should =~ /The survey you are trying to access has been removed/i
    end

    it 'should redirect to index if locked' do
      survey_version.stub(:locked).and_return true

      get :edit, survey_id: survey.id, id: survey_version.id

      response.should redirect_to(survey_survey_versions_path survey)
      flash[:notice].should =~ /You may not edit a survey once it has been published.  Please create a new version if you wish to make changes to this survey/i
    end

    it 'should render the edit template' do
      get :edit, survey_id: survey.id, id: survey_version.id

      response.should render_template(:edit)
    end
  end

  context 'show' do
    it 'should render the show template' do
      get :show, survey_id: survey.id, id: survey_version.id

      response.should render_template(:show)
    end
  end

  context 'update' do
    it 'should render edit template when model is invalid' do
      survey_version.stub(:update_attributes).and_return false

      put :update, survey_id: survey, id: survey_version, survey_version: { major: nil }

      response.should render_template(:edit)
    end

    it 'should redirect to index when model is valid' do
      survey_version.stub(:update_attributes).and_return true

      put :update, survey_id: survey, id: survey_version, survey_version: { notes: 'Test Notes' }

      response.should redirect_to(survey_survey_versions_path survey)
      flash[:notice].should =~ /Successfully updated the thank you page/i
    end
  end

  context 'destroy' do
    it 'should set archived true' do
      survey_version.should_receive(:update_attribute).with(:archived, true)

      delete :destroy, survey_id: survey.id, id: survey_version.id
    end

    it 'should redirect to index with message' do
      delete :destroy, survey_id: survey.id, id: survey_version.id

      response.should redirect_to(survey_survey_versions_path survey)
      flash[:notice].should =~ /Survey Version was successfully deleted./i
    end
  end
end
