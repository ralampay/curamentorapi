FactoryBot.define do
  factory :faculty do
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:middle_name) { |n| "Middle#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    sequence(:id_number) { |n| "FAC#{n}" }
  end
end
