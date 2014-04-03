require 'spec_helper'

describe TextQuestionsController do
  include Authlogic::TestCase

  let(:site) { create :site }
  let(:survey) { create :survey, { site: site } }
  let(:survey_version) { create :survey_version, { survey: survey } }
  let(:text_question) { mock_model(TextQuestion) }

  before do
    activate_authlogic
    user = User.create(email: "email@example.com", password: "password", password_confirmation: "password", f_name: "example", l_name: "user")
    user.sites << site
    UserSession.create user

    User.any_instance.stub_chain(:surveys, :find).and_return(survey)
    Survey.any_instance.stub_chain(:survey_versions, :find).and_return(survey_version)
  end

  context 'new' do
    before do
      survey_version.stub_chain(:text_questions, :build).and_return(text_question)
    end

    it 'should build a new TextQuestion' do
      survey_version.text_questions.should_receive(:build).and_return(text_question)
      get :new, survey_id: survey.id, survey_version_id: survey_version.id
    end

    it 'should render new' do
      get :new, survey_id: survey.id, survey_version_id: survey_version.id
      response.should render_template(:new)
    end

    it 'should render new.js' do
      get :new, survey_id: survey.id, survey_version_id: survey_version.id, format: :js
      response.should render_template(:new)
    end
  end

  context 'create' do
    before do
      TextQuestion.stub(:new).and_return(text_question)
      text_question.stub_chain(:survey_element, :survey_version_id=)
    end

    context 'valid text question' do
      before { text_question.stub(:save).and_return true }

      it 'should create a new TextQuestion' do
        TextQuestion.should_receive(:new).and_return(text_question)
        post :create, survey_id: survey.id, survey_version_id: survey_version.id
      end

      it 'should assign survey_version_id to SurveyElement of TextQuestion' do
        survey_element_double = double
        text_question.stub(:survey_element).and_return(survey_element_double)
        survey_element_double.should_receive(:survey_version_id=)
        post :create, survey_id: survey.id, survey_version_id: survey_version.id
      end

      it 'should redirect to show survey with message' do
        post :create, survey_id: survey.id, survey_version_id: survey_version.id
        response.should redirect_to(survey_path survey)
        flash[:notice].should =~ /Successfully added text question./i
      end

      it 'should render element_create.js' do
        post :create, survey_id: survey.id, survey_version_id: survey_version.id, format: :js
        response.should render_template('shared/_element_create')
      end
    end

    it 'should render new if validation fails' do
      text_question.stub(:save).and_return false
      post :create, survey_id: survey.id, survey_version_id: survey_version.id
      response.should render_template(:new)
    end
  end

  context 'edit' do
    it 'should ask the SurveyVersion for the appropriate TextQuestion' do
      text_questions_double = double
      survey_version.stub(:text_questions).and_return(text_questions_double)

      text_questions_double.should_receive(:find)

      get :edit, survey_id: survey.id, survey_version_id: survey_version.id, id: text_question.id
    end

    it 'should render edit' do
      survey_version.stub_chain(:text_questions, :find)

      get :edit, survey_id: survey.id, survey_version_id: survey_version.id, id: text_question.id

      response.should render_template(:edit)
    end

    it 'should render edit.js' do
      survey_version.stub_chain(:text_questions, :find)

      get :edit, survey_id: survey.id, survey_version_id: survey_version.id, id: text_question.id, format: :js

      response.should render_template(:edit)
    end
  end

  context 'update' do
    before(:each) do
      TextQuestion.stub(:find).and_return(text_question)
    end

    it 'should render edit if validation fails' do
      text_question.stub(:update_attributes).and_return false

      put :update, survey_id: survey.id, survey_version_id: survey_version.id, id: text_question.id

      response.should render_template(:edit)
    end

    it 'should redirect to show survey with message' do
      text_question.stub(:update_attributes).and_return true

      put :update, survey_id: survey.id, survey_version_id: survey_version.id, id: text_question.id

      response.should redirect_to(survey_path survey)
      flash[:notice].should =~ /Successfully updated text question./i
    end

    it 'should render element_create.js' do
      text_question.stub(:update_attributes)

      put :update, survey_id: survey.id, survey_version_id: survey_version.id, id: text_question.id, format: :js

      response.should render_template('shared/_element_create')
    end

    it 'should call mark_reports_dirty! if survey is published.' do
      text_question.stub(:update_attributes).and_return(true)
      survey_version.stub(:published?).and_return(true)
      survey_version.should_receive(:mark_reports_dirty!)
      put :update, survey_id: survey.id, survey_version_id: survey_version.id,
        id: text_question.id
    end
  end

  context 'destroy' do
    before do
      TextQuestion.stub(:find).and_return(text_question)
      controller.stub(:destroy_default_rule_and_display_field)
      text_question.stub(:destroy)
      text_question.stub(:question_content)
    end

    it 'should call for destruction of the TextQuestion' do
      text_question.should_receive(:destroy)
      delete :destroy, survey_id: survey.id, survey_version_id: survey_version.id, id: text_question.id
    end

    it 'should redirect to show survey with message' do
      delete :destroy, survey_id: survey.id, survey_version_id: survey_version.id, id: text_question.id

      response.should redirect_to(survey_path survey)
      flash[:notice].should =~ /Successfully deleted text question./i
    end

    it 'should render element_destroy.js' do
      delete :destroy, survey_id: survey.id, survey_version_id: survey_version.id, id: text_question.id, format: :js
      response.should render_template('shared/_element_destroy')
    end
  end
end
