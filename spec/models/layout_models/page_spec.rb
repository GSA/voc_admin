require "rails_helper"

RSpec.describe Page, type: :model do
  before(:each) { FactoryGirl.reload } # Reset sequences between each test

  it { should validate_presence_of(:page_number) }
  it { should validate_presence_of(:survey_version) }

  context ".previous_pages" do
    it "returns pages in the same survey_version with a lower page number" do
      survey_version = create(:survey_version)
      create_list :page, 2, survey_version: survey_version
      page = create :page, survey_version: survey_version
      expect(page.previous_pages.map(&:page_number)).to eq [1,2]
    end

    it "does not return pages with a higher page number" do
      survey_version = create(:survey_version)
      page = create :page, survey_version: survey_version
      create_list :page, 2, survey_version: survey_version
      expect(page.previous_pages.map(&:page_number)).to eq []
    end
  end

  context ".next_page" do
    it "returns the flow control target if there is one" do
      survey_version = create(:survey_version)
      pages = create_list :page, 3, survey_version: survey_version
      pages.first.update_attribute(:next_page, pages.last)
      expect(pages.first.next_page).to eq pages.last
    end

    it "returns the next page by page number without flow control" do
      survey_version = create(:survey_version)
      pages = create_list :page, 3, survey_version: survey_version
      expect(pages.first.next_page).to eq pages.second
    end
  end

  context ".clone_me" do
    it "sets the clone_of_id" do
      page = create :page
      target_sv = create :survey_version
      cloned_page = page.clone_me(target_sv)
      expect(cloned_page.clone_of_id).to eq page.id
    end

    it "adds the page to the target survey version" do
      page = create :page
      target_sv = create :survey_version
      expect{page.clone_me(target_sv)}.to change {target_sv.pages.count}.by(1)
    end
  end

  context ".create_copy" do
    it "adds creates a new page to the end of the survey version" do
      survey_version = create :survey_version
      page = create :page, survey_version: survey_version
      expect{page.create_copy}.to change {survey_version.pages.count}.by(1)
    end

    it "copies page survey elements to the new page" do
      survey_version = create :survey_version
      page = create :page, survey_version: survey_version
      snippet = create :asset, survey_element: create(
        :survey_element, page: page, survey_version: survey_version
      )
      new_page = page.create_copy
      expect(new_page.survey_elements.count).to eq 1
      expect(new_page.survey_elements.first.assetable.snippet).to eq snippet.snippet
    end

    it "does not copy survey elements from other pages" do
      survey_version = create :survey_version
      page = create :page, survey_version: survey_version
      create :asset, survey_element: create(
        :survey_element, page: page, survey_version: survey_version
      )
      create :asset, snippet: "Not Copied",
        survey_element: create(:survey_element,
                               page: create(:page, survey_version: survey_version),
                               survey_version: survey_version
                              )
      new_page = page.create_copy
      expect(new_page.survey_elements.count).to eq 1
    end
  end
end
