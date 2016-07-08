FactoryGirl.define do
  factory :asset do
    snippet "Default Snippet Text"
    association(:survey_element)
  end
end
