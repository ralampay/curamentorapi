FactoryBot.define do
  factory :author do
    association :publication
    association :person, factory: :student
    is_primary { false }
  end
end
