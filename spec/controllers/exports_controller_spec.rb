require 'spec_helper'

describe ExportsController do

  describe "GET 'download'" do
    it "returns http success" do
      get 'download'
      response.should be_success
    end
  end

end
