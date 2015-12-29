FactoryGirl.define do
  factory :survey_type do
    sequence(:name) { |n| "Default Survey Type #{n}" }
  end
end
