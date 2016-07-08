FactoryGirl.define do
  factory :survey_version do
    major 1
    sequence(:minor)
    association(:survey)

    trait :published do
      published { true }
    end
  end
end
