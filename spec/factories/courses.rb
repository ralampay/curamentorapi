FactoryBot.define do
  factory :course do
    sequence(:name) { |n| "Course #{n}" }
    sequence(:code) { |n| "CODE#{n}" }
  end
end
