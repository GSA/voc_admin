require 'spec_helper'

describe SurveysController do
  include Authlogic::TestCase
  
  context "when a user is logged in" do
    before(:each) do
      activate_authlogic
      UserSession.create User.create(:email => "email@example.com", :password => "password", :password_confirmation => "password", :f_name => "example", :l_name => "user")
    end

    describe "GET 'Index'" do
      it "gets the index view" do
        get "index"
        response.status.should be 200
      end

      it "gets the correct index template" do
        get "index"
        response.should render_template("surveys/index")
      end
    end    
  end ## End context user is logged in
  
end