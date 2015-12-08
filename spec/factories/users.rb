FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "test_user_#{n}@example.com"}
    fullname { "John Doe " }
    sequence(:hhs_id) {|n| 2000000000 + n}

    trait :admin do
      role_id { Role::ADMIN.id }
    end
  end
end
