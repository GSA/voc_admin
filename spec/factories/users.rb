FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "test_user_#{n}@example.com"}
    f_name "John"
    l_name "Doe"
    username "jdoe"

    trait :admin do
      role_id { Role::ADMIN.id }
    end
  end
end
