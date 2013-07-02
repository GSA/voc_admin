require 'spec_helper'

describe DisplayFieldObserver do
  # shouldn't this test be performed in DisplayField?
  it "should create a display field value entry for each existing survey response"

  context "after_create" do
    it "should have a proper test for Redis"
    # it "should call delay.populate_default_values!" do
    #   df = mock_model(DisplayField)

    #   DisplayFieldObserver.instance.stub(:delay).and_return(df)

    #   df.stub(:populate_default_values!)
    #   df.should_receive(:populate_default_values!)

    #   DisplayFieldObserver.instance.after_create df
    # end
  end

  context "after_destroy" do
    it "should compact the display fields when a display field is destroyed" do
      survey = create :survey
      df1 = DisplayFieldText.create! :name => "df1", :display_order => 1, :survey_version => survey.survey_versions.first
      df2 = DisplayFieldText.create! :name => "df2", :display_order => 2, :survey_version => survey.survey_versions.first

      df1.destroy

      df2.reload.display_order.should == 1
    end
  end
end
