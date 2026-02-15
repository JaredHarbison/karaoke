FactoryBot.define do
  factory :venue_admin do
    association :venue
    association :user, role: :admin
    
    trait :with_owner_and_admin do
      association :venue, factory: :venue
      association :user, factory: :user, role: :admin
    end
  end
end
