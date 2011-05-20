require 'spec_helper'

describe SurveysController do
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
end