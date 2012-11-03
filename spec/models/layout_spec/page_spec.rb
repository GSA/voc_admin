require 'spec_helper'

describe Page do

  before(:each) do
    @page = Page.new(
      :page_number => 1,
      :survey_version => mock_model(SurveyVersion, :version_number => "1.0", :touch => nil)
    )
  end

  it "should be valid" do
    @page.should be_valid
  end

  it "should not be valid without a page number" do
    @page.page_number = nil
    @page.should_not be_valid
  end

  it "should not be valid without a unique page number in the current survey_version" do
    @page.dup.save
    @page.should_not be_valid
  end

  it "should be valid the same page number as another page in another survey_version" do
    page2 = @page.dup
    page2.survey_version = mock_model(SurveyVersion)
    @page.should be_valid
  end

  it "should not be valid without a survey version" do
    @page.survey_version = nil
    @page.should_not be_valid
  end

  it "should return the next page object" do
    version = SurveyVersion.create!(
      :survey => build(:survey),
      :major => 1,
      :minor => 0
    )

    2.times do
      version.pages.create! :page_number => version.next_page_number
    end

    version.pages.first.next_page.page_number.should == 2
    version.pages.last.next_page.should be nil
  end

  it "should return the previous page object" do
    version = SurveyVersion.create!(
      :survey => build(:survey),
      :major => 1,
      :minor => 0,
      :touch => nil
    )

    2.times do
      version.pages.create! :page_number => version.next_page_number
    end

    version.pages.first.prev_page.should be nil
    version.pages.last.prev_page.page_number.should == 1
  end

  it "should change the page number to the provided position and update all other pages" do
    version = SurveyVersion.create!(
      :survey => build(:survey),
      :major => 1,
      :minor => 0
    )

    4.times do |i|
      version.pages.create! :page_number => version.next_page_number
    end

    original_order = version.pages.order('page_number asc').map &:id

    page = version.pages.first
    page.move_page_to(2)
    page.reload
    page.page_number.should == 2
    version.pages.order('page_number asc').map(&:id).should == [original_order[1], original_order[0], original_order[2], original_order[3]]

    page = version.pages.last
    page.move_page_to(1)
    page.reload
    page.page_number.should == 1
    version.pages.order('page_number asc').map(&:id).should == [original_order[3], original_order[1], original_order[0], original_order[2]]
  end

  it "should renumber all pages after destroy" do
    survey = create :survey
    version = survey.survey_versions.first
    3.times {version.pages.create! :page_number => version.next_page_number}
    version.pages.first.destroy
    version.reload
    version.pages.should have(3).pages
    version.pages.map(&:page_number).should == [1,2,3]
  end

  it "should clone it self to new survey version" do
    @page.save!
    clone_page = @page.clone_me(mock_model(SurveyVersion, :touch => nil))
    clone_page.page_number.should == @page.page_number
    clone_page.style_id.should == @page.style_id
    clone_page.clone_of_id.should == @page.id
  end

end