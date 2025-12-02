FactoryBot.define do
  factory :student do
    association :course
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.middle_name }
    last_name { Faker::Name.last_name }
    sequence(:id_number) { |n| "ID#{n}" }
    sequence(:email) { |n| "student#{n}@example.com" }
  end
end
