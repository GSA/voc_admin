require 'spec_helper'

describe DisplayFieldsController do
  before(:each) do
    @display_field_text = DisplayFieldText.new(:name=>"Test", :display_order=>1, :survey_version => mock_model(SurveyVersion, :survey_responses => []))
    DisplayFieldObserver.instance.stub(:after_create).and_return(true)
  end

  context "destroy" do

    it "should renumber the display_order for the remaining display fields" do
      df1 = @display_field_text.dup
      df1.save!

      df2 = @display_field_text.dup
      df2.name = "Test Display FIeld 2"
      df2.display_order = 2
      df2.save!

      df1.display_order.should == 1
      df2.display_order.should == 2

      SurveyVersion.stub_chain(:find, :display_fields, :order, :where).and_return(DisplayField.where(:id => df2.id))

      DisplayFieldsController.stub(:get_survey_version).and_return(true)
      DisplayField.stub(:find).and_return(df1)

      post :destroy, :id => df1.id, :survey_version_id => 1, :survey_id => 1

      df2.reload.display_order.should == 1
    end
  end # destroy
end