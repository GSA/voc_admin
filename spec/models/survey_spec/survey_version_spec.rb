require 'spec_helper'

describe SurveyVersion do
  before(:each) do
    @survey = create :survey
  end

  it { should validate_presence_of(:major) }
  it { should validate_numericality_of(:major) }
  it { should validate_uniqueness_of(:major).scoped_to([:survey_id, :minor]) }

  it { should validate_presence_of(:minor) }
  it { should validate_numericality_of(:minor) }
  it { should validate_uniqueness_of(:minor).scoped_to([:survey_id, :major]) }

  it { should ensure_length_of(:notes).is_at_most(65535) }

  it { should validate_presence_of(:survey) }

  # these are not in Shoulda 1.4.0, but coming soon:
  # it { should delegate_method(:name).to(:survey) }
  # it { should delegate_method(:description).to(:survey) }

  context "scope tests" do
    before(:each) do
      @sv = build :survey_version
    end

    context "published scope" do
      it "should include published SurveyVersions" do
        @sv.published = true
        @sv.save!

        SurveyVersion.published.should include(@sv)
      end

      it "should not include unpublished SurveyVersions" do
        @sv.published = false
        @sv.save!

        SurveyVersion.published.should_not include(@sv)
      end
    end

    context "unpublished scope" do
      it "should include unpublished SurveyVersions" do
        @sv.published = false
        @sv.save!

        SurveyVersion.unpublished.should include(@sv)
      end

      it "should not include published SurveyVersions" do
        @sv.published = true
        @sv.save!

        SurveyVersion.unpublished.should_not include(@sv)
      end
    end

    context "archived scope" do
      it "should include archived SurveyVersions" do
        @sv.archived = true
        @sv.save!

        SurveyVersion.get_archived.should include(@sv)
      end

      it "should not include unarchived SurveyVersions" do
        @sv.archived = false
        @sv.save!

        SurveyVersion.get_archived.should_not include(@sv)
      end
    end

    context "unarchived scope" do
      it "should include unarchived SurveyVersions" do
        @sv.archived = false
        @sv.save!

        SurveyVersion.get_unarchived.should include(@sv)
      end

      it "should not include archived SurveyVersions" do
        @sv.archived = true
        @sv.save!

        SurveyVersion.get_unarchived.should_not include(@sv)
      end
    end
  end

  it "calling publish_me should set the version to published" do
    @survey.survey_versions.first.publish_me
    @survey.survey_versions.first.published.should == true
  end

  it "should return the next page number" do
    @survey.survey_versions.first.next_page_number.should == @survey.survey_versions.first.pages.count + 1
  end

  it "should return the next element number" do
    @survey.survey_versions.first.next_element_number.should == 1
  end

  it "should reorder all survey elements"

  it "should clone itself to create a new minor version" do
    @survey.survey_versions.last.clone_me
    @survey.survey_versions.should have(2).records
    @survey.survey_versions.first.major.should == @survey.survey_versions.last.major
    @survey.survey_versions.last.minor.should == (@survey.survey_versions.first.minor + 1)
    @survey.survey_versions.last.published == false
    @survey.survey_versions.first.notes == @survey.survey_versions.last.notes
  end

  it "should return a source array to be used in rule creation"

  it "should return an array of question_content ids "
end