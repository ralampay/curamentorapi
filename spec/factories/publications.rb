FactoryBot.define do
  factory :publication do
    sequence(:title) { |n| "Publication #{n}" }
    date_published { Faker::Date.backward(days: 365) }
  end
end
