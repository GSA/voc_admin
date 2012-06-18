require 'spec_helper'

describe DisplayFieldObserver do
  it "should create a display field value entry for each existing survey response"

  it "should compact the display fields when a display field is destroyed" do
    survey = create :survey
    df1 = DisplayFieldText.create! :name => "df1", :display_order => 1, :survey_version => survey.survey_versions.first
    df2 = DisplayFieldText.create! :name => "df2", :display_order => 2, :survey_version => survey.survey_versions.first

    df1.destroy

    df2.reload.display_order.should == 1      
  end
end
