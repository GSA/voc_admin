FactoryGirl.define do
  factory :survey_version do
    major 1
    sequence(:minor)
    association(:survey)
  end
end
