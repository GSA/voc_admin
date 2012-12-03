require 'spec_helper'

describe PollResults do
	before(:each) do
    @answer_counts = { "1" => 17, "2" => 17, "4" => 13, "3" => 12 }

    PollResults.any_instance.stub_chain(:survey_version, :choice_questions, :where, :limit)
    @poll_results = PollResults.new(mock_model SurveyVersion)
	end
	
  it "should calculate answer counts" do
    RawResponse.stub_chain(:unscoped, :includes, :where, :group, :order, :count)
               .and_return({ "1,2" => 1,  "1" => 4, "2" => 3, "1,2,3" => 7, "4" => 5,
                             "2,4" => 3, "1,3,4" => 2, "1,2,3,4" => 3 })

    ChoiceQuestion.any_instance.stub_chain(:question_content, :id)

    # test both contents and order of the returned hash
    @poll_results.answer_counts_for_question(stub_model ChoiceQuestion).flatten
                 .should eq(@answer_counts.flatten)
  end

  it "should total all answers per question" do
    PollResults.any_instance.stub(:answer_counts_for_question).and_return(@answer_counts)

    @poll_results.total_answers_for_question(mock_model ChoiceQuestion).should eq(59)
  end
end

