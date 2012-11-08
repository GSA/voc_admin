require 'spec_helper'

describe SurveyElement do
  
  before(:each) do
    @survey = create :survey
    @version = @survey.survey_versions.first
    @page = @version.pages.create! :page_number => @version.next_page_number
    @asset = Asset.create! :snippet => "HTML Snippet"  
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
    before(:each) do
      @element1 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => @asset.id, :page_id => @page.id)
      @element2 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => Asset.create!(:snippet => "Snippet2").id, :page_id => @page.id)
    end

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
      @element2.reload.element_order.should == 1
    end

    it "should increment element order" do
      @element1.move_element_down
      @element1.element_order.should == 2
    end
  
    it "should decrement element order" do
      @element2.move_element_up
      @element2.element_order.should == 1   
    end

    it "should call set_element_order before validation" do
      element = @version.survey_elements.new(:assetable => mock_model(Asset))
      element.should_receive(:set_element_order).once
      element.valid?
    end
  end
  
  it "should set element_order to the next number" do
    element = SurveyElement.new(:page => @page, :survey_version => @version)
    # element.send(:set_element_order)
    # element.element_order.should == 1
    element.save!
    element.element_order.should == 1
    element_2 = SurveyElement.new(:page => @page, :survey_version => @version)
    element_2.save!
    element_2.element_order.should == 2
    
    page_2 = @version.pages.create! :page_number => @version.next_page_number
    element_3 = SurveyElement.new(:page => page_2, :survey_version => @version)
    element_3.save!
    element_3.element_order.should == 3
    
    element_4 = SurveyElement.new(:page => @page, :survey_version => @version)
    element_4.save!
    element_4.element_order.should == 3
    element_3.reload.element_order.should == 4
  end
  
  it "should clone it self" do
    element1 = @version.survey_elements.create!(:assetable_type => "Asset", :assetable_id => @asset.id, :page_id => @page.id)
    asset_2 = Asset.create! :snippet => "Snippet2"
    clone_sv = @version.clone_me
    clone_sv.survey_elements.should have(@version.survey_elements.size).records
  end
end