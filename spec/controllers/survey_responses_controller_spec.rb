require 'spec_helper'

describe SurveyResponsesController do
  include Authlogic::TestCase

  before do
    activate_authlogic
    UserSession.create User.create(:email => "email@example.com", :password => "password", :password_confirmation => "password", :f_name => "example", :l_name => "user")
  end

  def valid_attributes
    {}
  end

  context "GET Index" do
    it "should render the index template" do
      get :index
      response.should render_template(:index)
    end

    it "should assign @survey_version if params[:survey_version_id] is present" do
      sv = mock_model(SurveyVersion, :present? => false)

      SurveyVersion.stub(:find).and_return(sv)

      get :index, :survey_version_id => 1
      assigns(:survey_version).should == sv
    end

    it "should raise an error if params[:survey_version_id] is not a valid id" do
      lambda { get :index, :survey_version_id => 999 }.should raise_error ActiveRecord::RecordNotFound
    end

    it "should assign nil to @survey_version if params[:survey_version_id] is nil" do
      get :index
      assigns(:survey_version).should be_nil
    end

    it "should return a csv download" do
      @request.env["HTTP_ACCEPT"] = "text/csv"
      sv = mock_model(SurveyVersion, :display_fields => DisplayField.scoped, :survey_responses => SurveyResponse.scoped)
      SurveyResponsesController.any_instance.stub(:set_custom_view)
      SurveyVersion.stub(:find).and_return(sv)
      get :index, :survey_version_id => 1
      response.headers['Content-Type'].index("text/csv").should_not be_nil
    end
  end
end
