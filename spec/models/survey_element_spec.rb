require 'spec_helper'

describe SurveyElement do
  
  before(:each) do
    @survey = Survey.create! :name => "Test Survey", :description => "RSpec Survey"
    @version = @survey.survey_versions.first
    @page = @version.pages.create! :page_number => @version.next_page_number
    @asset = Asset.create! :snippet => "HTML Snippet"    
  end
  
  it "should have a page" do
    element = @version.survey_elements.new(:assetable_type => "Asset", :assetable_id => @asset.id).should_not be_valid
  end
  
  it "should have a survey version" do
    element = SurveyElement.new(:assetable_type => "Asset", :assetable_id => @asset.id, :page_id => @page.id).should_not be_valid
  end
  
  it "should have an element order set" do
    element = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => @asset.id, :page_id => @page.id)
    element.element_order = nil
    element.should_not be_valid
  end
  
  it "should have a unique element order" do
    element1 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => @asset.id, :page_id => @page.id)
    asset_2 = Asset.create! :snippet => "Snippet2"
    element2 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => asset_2.id, :page_id => @page.id)
    element2.element_order = 1
    element2.should_not be_valid
  end
  
  it "should reorder page elements when an element is destroyed" do
    element1 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => @asset.id, :page_id => @page.id)
    asset_2 = Asset.create! :snippet => "Snippet2"
    element2 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => asset_2.id, :page_id => @page.id)
    element1.destroy
    element2.reload.element_order.should == 1
  end
  
  it "should increment element order" do
    element1 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => @asset.id, :page_id => @page.id)
    asset_2 = Asset.create! :snippet => "Snippet2"
    element2 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => asset_2.id, :page_id => @page.id)
    element1.move_element_down
    element1.element_order.should == 2
  end
  
  it "should decrement element order" do
    element1 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => @asset.id, :page_id => @page.id)
    asset_2 = Asset.create! :snippet => "Snippet2"
    element2 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => asset_2.id, :page_id => @page.id)
    element2.move_element_up
    element2.element_order.should == 1   
  end
  
  it "should swap element orders" do
    element1 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => @asset.id, :page_id => @page.id)
    asset_2 = Asset.create! :snippet => "Snippet2"
    element2 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => asset_2.id, :page_id => @page.id)
    element2.swap_elements(element1)
    [element1.element_order, element2.element_order].should == [2,1]    
  end
  
end