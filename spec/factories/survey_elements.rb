FactoryGirl.define do
  factory :survey_element do
    association(:survey_version)
    association(:page)
  end
end
