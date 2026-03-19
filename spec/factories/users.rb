FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    role { :user }
    active { true }
    association :company

    trait :admin do
      role { :admin }
    end

    trait :super_admin do
      role { :super_admin }
      company { nil }
    end

    trait :inactive do
      active { false }
    end
  end
end
