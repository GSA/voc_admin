FactoryGirl.define do
  factory :site do 
    sequence(:name) {|n| "Test Site #{n}"}
    sequence(:url)  {|n| "https://test#{n}.com" }
    description  "Test Site"
  end
end
