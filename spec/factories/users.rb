FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "test_user_#{n}@example.com"}
    f_name "John"
    l_name "Doe"
    sequence(:hhs_id) {|n| 2000000000 + n}
    role_id { nil }

    trait :admin do
      role_id { Role::ADMIN.id }
    end
  end
end
