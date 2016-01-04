FactoryGirl.define do
  factory :survey do
    sequence(:name) {|n| "Test Survey #{n}"}
    description     "This is a test survey created by RSpec and FactoryGirl"
    association(:site)
    association(:survey_type)

    trait :site do
      association(:survey_type, id: SurveyType::SITE, name: "Site")
    end
  end
end
