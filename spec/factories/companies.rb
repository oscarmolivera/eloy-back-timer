FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Acme Corporation #{n}" }
  end
end
