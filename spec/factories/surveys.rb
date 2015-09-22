FactoryGirl.define do
  factory :survey do
    sequence(:name) {|n| "Test Survey #{n}"}
    description     "This is a test survey created by RSpec and FactoryGirl"
    association(:site)
  end
end
