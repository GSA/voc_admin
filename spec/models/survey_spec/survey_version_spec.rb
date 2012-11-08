require 'spec_helper'

describe SurveyVersion do
  before(:each) do
    @survey = create :survey
    @version = @survey.survey_versions.first
  end

  it { should validate_presence_of(:major) }
  it { should validate_numericality_of(:major) }
  it { should validate_uniqueness_of(:major).scoped_to([:survey_id, :minor]) }

  it { should validate_presence_of(:minor) }
  it { should validate_numericality_of(:minor) }
  it { should validate_uniqueness_of(:minor).scoped_to([:survey_id, :major]) }

  it { should ensure_length_of(:notes).is_at_most(65535) }

  it { should validate_presence_of(:survey) }

  it "should touch the survey" do
    @version.survey.should_receive(:touch)
    @version.minor = 4
    @version.save!
  end

  context "scope tests" do
    context "published scope" do
      it "should include published SurveyVersions" do
        @version.published = true
        @version.save!

        SurveyVersion.published.should include(@version)
      end

      it "should not include unpublished SurveyVersions" do
        @version.published = false
        @version.save!

        SurveyVersion.published.should_not include(@version)
      end
    end

    context "unpublished scope" do
      it "should include unpublished SurveyVersions" do
        @version.published = false
        @version.save!

        SurveyVersion.unpublished.should include(@version)
      end

      it "should not include published SurveyVersions" do
        @version.published = true
        @version.save!

        SurveyVersion.unpublished.should_not include(@version)
      end
    end

    context "archived scope" do
      it "should include archived SurveyVersions" do
        @version.archived = true
        @version.save!

        SurveyVersion.get_archived.should include(@version)
      end

      it "should not include unarchived SurveyVersions" do
        @version.archived = false
        @version.save!

        SurveyVersion.get_archived.should_not include(@version)
      end
    end

    context "unarchived scope" do
      it "should include unarchived SurveyVersions" do
        @version.archived = false
        @version.save!

        SurveyVersion.get_unarchived.should include(@version)
      end

      it "should not include archived SurveyVersions" do
        @version.archived = true
        @version.save!

        SurveyVersion.get_unarchived.should_not include(@version)
      end
    end
  end

  # these are not in Shoulda 1.4.0, but coming soon:
  # it { should delegate_method(:name).to(:survey) }
  # it { should delegate_method(:description).to(:survey) }

  context "export responses to CSV" do

    # TODO: should be refactored into many small pieces
    it "should generate filtered CSV responses and email the user"
  end

  context "should package question statement and id for consumption elsewhere" do
    # wanted to write this all in FactoryGirl but while "through" is clear, "source" is not
    # and the relationships are a bit complex
    before(:each) do
      QuestionContentObserver.any_instance.stub(:after_create)
      @page = @version.pages.first || @version.pages.create!(:page_number => 1)

      generate_choice_question
      generate_text_question
      generate_matrix_question
    end

    it "should return a source array to be used in rule creation" do
      sources = @version.sources
      
      sources.should have(3).Array
      sources.each do |s|
        s.should have(2).String
        s.first.should match(/\d+,QuestionContent/)
      end
      sources.first.last.should match(/Rspec Choice Question\(Question\)/)
      sources.second.last.should match(/Rspec Text Question\(Question\)/)
      sources.third.last.should match(/Matrix Question 1: Row 1\(matrix answer\)/)
    end

    it "should return an array of question_content ids for drop-down selection" do
      options = @version.options_for_action_select

      options.should have(3).Array
      options.each do |o|
        o.should have(2).String
        o.second.should match(/\d+/)
      end
      
      options.first.first.should match(/Rspec Choice Question response/)
      options.second.first.should match(/Rspec Text Question response/)
      options.third.first.should match(/Matrix Question 1: Row 1 response/)
    end
  end

  it "should return the next page number" do # TODO: this test could be better
    @survey.survey_versions.first.next_page_number.should == @survey.survey_versions.first.pages.count + 1
  end

  it "should return the next element number" do # TODO: this test could be better
    @survey.survey_versions.first.next_element_number.should == 1
  end

  it "should format the version number" do
    @survey_version = @survey.survey_versions.first
    @survey_version.major = 6
    @survey_version.minor = 5

    @survey_version.version_number.should == "6.5"
  end

  it "calling publish_me should set the version to published" do
    @survey.survey_versions.first.publish_me
    @survey.survey_versions.first.published.should be_true
  end

  it "calling unpublish_me should set the version to unpublished" do
    @survey.survey_versions.first.unpublish_me
    @survey.survey_versions.first.published.should be_false
  end

  it "should clone itself to create a new minor version" do
    @survey.survey_versions.last.clone_me
    @survey.survey_versions.should have(2).records
    @survey.survey_versions.first.major.should == @survey.survey_versions.last.major
    @survey.survey_versions.last.minor.should == (@survey.survey_versions.first.minor + 1)
    @survey.survey_versions.last.published == false
    @survey.survey_versions.first.notes == @survey.survey_versions.last.notes
  end

  def generate_choice_question
    @choice = ChoiceQuestion.new( :answer_type => "radio" )
    @choice.build_question_content :statement => "Rspec Choice Question",
                                   :questionable => @choice,
                                   :questionable_type => "ChoiceQuestion"

    @choice.build_survey_element(
      :element_order => 1,
      :survey_version => @version,
      :page => @page
    )

    @choice.choice_answers.build :answer => "Answer 1"

    @choice.save!
  end

  def generate_text_question
    @text = TextQuestion.new( :answer_type => "area" )
    @text.build_question_content :statement => "Rspec Text Question",
                                 :questionable => @text,
                                 :questionable_type => "TextQuestion"

    @text.build_survey_element(
      :element_order => 2,
      :survey_version => @version,
      :page => @page
    )
    @text.save!
  end

  def generate_matrix_question
    @matrix = MatrixQuestion.new

    @matrix.build_survey_element(
      :element_order => 3, 
      :survey_version => @version,
      :page => @page
    )

    @matrix.build_question_content :statement => "Matrix Question 1"

    m_choice = @matrix.choice_questions.build :answer_type => 'radio'
    m_choice.create_question_content :statement => "Row 1"
    m_choice.choice_answers.build :answer => "Answer A"

    @matrix.save!
  end
end