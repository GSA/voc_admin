require 'spec_helper'

describe SurveyElement do

  before(:each) do
    @survey = create :survey
    @version = @survey.survey_versions.first
    @page = @version.pages.create! :page_number => @version.next_page_number
    @asset = Asset.create! :snippet => "HTML Snippet"
    @element1 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => @asset.id, :page_id => @page.id)
    @element2 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => Asset.create!(:snippet => "Snippet2").id, :page_id => @page.id)
  end

  it "should be valid" do
    @version.survey_elements.new(:assetable => @asset, :page => @page).should be_valid
  end

  it "should have a page" do
    element = @version.survey_elements.new(:assetable_type => "Asset", :assetable_id => @asset.id).should_not be_valid
  end

  it "should have a survey version" do
    element = SurveyElement.new(:assetable_type => "Asset", :assetable_id => @asset.id, :page_id => @page.id).should_not be_valid
  end

  context "element ordering" do
    it "should have an element order set" do
      @element1.element_order = nil
      @element1.should_not be_valid
    end

    it "should have a unique element order" do
      @element2.element_order = 1
      @element2.should_not be_valid
    end

    it "should order by element_order by default" do
      @version.survey_elements.should == @version.survey_elements.order(:element_order)
    end

    it "should reorder page elements when an element is deleted" do
      @element1.destroy
      @element2.reload.element_order.should eq(1)
    end

    it "should increment element order" do
      @element1.move_element_down
      @element1.element_order.should eq(2)
    end

    it "should decrement element order" do
      @element2.move_element_up
      @element2.element_order.should eq(1)
    end

    it "should call set_element_order before validation" do
      element = @version.survey_elements.new(:assetable => mock_model(Asset))
      element.should_receive(:set_element_order).once
      element.valid?
    end
  end

  context "moving to end of the page" do
    it "should return false if it has no page id" do
      @element1.page_id = nil
      @element1.move_to_end_of_page.should be_false
    end

    it "should return the maximum index of the page plus 1" do
      @element1.element_order.should eq(1)
      @element1.move_to_end_of_page
      @element1.element_order.should eq(@page.survey_elements.maximum(:element_order).to_i + 1)
    end
  end

  it "should be copyable to another page" do
    @element1.assetable.stub(:copy_to_page).and_return(@element1.assetable)
    @element1.assetable.should_receive(:survey_element).once

    @element1.copy_to_page(@page)
  end

  it "should set element_order to the next number for the page" do
    page = @version.pages.first
    element_3 = @version.survey_elements.create :assetable_type => "Asset",
      :assetable_id => Asset.create(:snippet => "Asset 3").id,
      :page_id => page.id
    expect(element_3.element_order).to eq(page.survey_elements.count)
  end

  it "should clone it self" do # this test smells bad
    asset_2 = Asset.create! :snippet => "Snippet2"
    element1 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => asset_2.id, :page_id => @page.id)
    clone_sv = @version.clone_me
    clone_sv.survey_elements.should have(@version.survey_elements.size).records
  end
end
