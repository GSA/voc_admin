FactoryGirl.define do
  factory :page do
    page_number 1
    association(:survey_version)
  end
end
