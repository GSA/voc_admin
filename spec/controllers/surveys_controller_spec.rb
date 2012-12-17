require 'spec_helper'

describe SurveysController do
  include Authlogic::TestCase
  
  let(:site) { create :site }
  let(:survey) { create :survey, { :site => site }}

  context "when a user is logged in" do
    before(:each) do
      activate_authlogic
      user = User.create(:email => "email@example.com", :password => "password", :password_confirmation => "password", :f_name => "example", :l_name => "user")
      user.sites << site
      UserSession.create user
    end

    describe "index" do
      it "should get the index view" do
        User.any_instance.stub_chain(:surveys, :search, :order, :page, :per)

        get :index

        response.should render_template(:index)
      end
    end

    describe "new" do
      it "should get the new view" do
        User.any_instance.stub_chain(:surveys, :new)

        get :new

        response.should render_template(:new)
      end
    end

    describe "create" do
      before(:each) do
        User.any_instance.stub_chain(:surveys, :new).and_return(survey)
      end

      it "should redirect to edit survey with message on create" do
        Survey.any_instance.stub(:save).and_return true

        post :create

        response.should redirect_to(edit_survey_survey_version_path survey, survey.survey_versions.first)
        flash[:notice].should =~ /Survey was successfully created./i
      end

      it "should render new view if validation fails" do
        Survey.any_instance.stub(:save).and_return false

        post :create
        response.should render_template(:new)
      end

    end
  end
end