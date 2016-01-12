require "rails_helper"

RSpec.describe SurveyResponse, type: :model do
  it { should validate_presence_of(:survey_version) }

  context "#process_response" do
    it "creates a new survey response" do
      survey_version = create :survey_version
      response_params = {
        'page_url' => 'http://example.com',
        'device' => 'Desktop'
      }

      expect{SurveyResponse.process_response(response_params, survey_version.id)}
        .to change { SurveyResponse.count }.by(1)
    end

    it "creates a raw_response for each question answer" do
      survey_version = create :survey_version
      text_question = create :text_question, survey_version: survey_version,
        question_content: create(:question_content, statement: "Text Question")

      response_params = {
        "page_url" => "http://example.com",
        "device" => "Desktop",
        "raw_responses_attributes" => {
          "0" => {
            "question_content_id" => text_question.question_content.id.to_s,
            "answer" => "Test Answer"
          }
        }
      }

      expect{SurveyResponse.process_response(response_params, survey_version.id)}
        .to change {RawResponse.count}.by(1)
    end

    it "creates a display field value with the answer text" do
      survey_version = create :survey_version
      text_question = create :text_question, survey_version: survey_version,
        question_content: create(:question_content, statement: "Text Question")

      response_params = {
        "page_url" => "http://example.com",
        "device" => "Desktop",
        "raw_responses_attributes" => {
          "0" => {
            "question_content_id" => text_question.question_content.id,
            "answer" => "Test Answer"
          }
        }
      }

      expect{SurveyResponse.process_response(response_params, survey_version.id)}
        .to change {DisplayFieldValue.count}.by(1)

      dfv = DisplayFieldValue.last
      expect(dfv.value).to eq "Test Answer"
    end
  end
end
