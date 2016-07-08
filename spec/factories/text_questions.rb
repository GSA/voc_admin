FactoryGirl.define do
  factory :text_question do
    answer_type "field"
    association(:question_content)
    association(:survey_version)
  end
end
