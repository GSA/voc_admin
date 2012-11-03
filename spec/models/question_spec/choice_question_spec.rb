require "spec_helper"

describe ChoiceQuestion do
  before(:each) do
    @survey = create :survey
    @version = @survey.survey_versions.first
    @page = @version.pages.first || @version.pages.create!(:page_number => 1)

    @choice_question = ChoiceQuestion.new(
      :answer_type => "radio",
      :question_content_attributes => {:statement => "RSpec choice Question"}
    )

    @choice_question.build_survey_element(
      :element_order => 1,
      :survey_version => @version,
      :page => @page
    )

    @choice_question.choice_answers.build :answer => "answer 1"
  end

  it "should be valid" do
    @choice_question.should be_valid
  end

  it "should not be valid without a question content" do
    @choice_question.question_content = nil
    @choice_question.should_not be_valid
  end

  it "should not be valid without at least one answer" do
    @choice_question.choice_answers = []
    @choice_question.should_not be_valid
  end

  it "should not be valid without an answer type" do
    @choice_question.answer_type = nil
    @choice_question.should_not be_valid
  end

  it "should return the correct answer answers when given a properly formated response string"

  it "should return a survey_version" do
    @choice_question.survey_version.should_not be_nil
    @choice_question.survey_version.should == @choice_question.survey_element.survey_version
  end

  it "should check whether a given condition is met for a given response and test string"

  it "should clone it self" do
    @choice_question.choice_answers.should have(1).answer

    @choice_question.should be_valid

    @choice_question.save!

    target_version = @survey.create_new_major_version
    target_version.pages.first.update_attribute(:clone_of_id, @page.id)
    #target_version.pages.create! :page_number => 1, :clone_of_id => @page.id

    cloned_question = @choice_question.clone_me(target_version)

    cloned_question.should be_valid
    cloned_question.survey_element.should_not be_nil
    cloned_question.survey_element.should be_valid
    cloned_question.survey_element.survey_version.should_not be_nil
    cloned_question.survey_version.should == target_version
    cloned_question.answer_type.should == @choice_question.answer_type
    cloned_question.question_content.statement.should == @choice_question.question_content.statement
    cloned_question.choice_answers.should have(1).answer
    cloned_question.choice_answers.first.answer.should == @choice_question.choice_answers.first.answer
  end


end