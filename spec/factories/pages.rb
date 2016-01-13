FactoryGirl.define do
  factory :page do
    sequence(:page_number) {|n| n}
    association(:survey_version)
  end
end
