FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'SecurePassword123!' }
    password_confirmation { 'SecurePassword123!' }
    role { :performer }
    
    trait :owner do
      role { :owner }
    end
    
    trait :admin do
      role { :admin }
    end
    
    trait :performer do
      role { :performer }
    end
    
    trait :with_venue do
      association :venue, factory: :venue
    end
    
    trait :as_venue_owner do
      transient do
        owned_venue { nil }
      end
      
      after(:create) do |user, evaluator|
        evaluator.owned_venue ||= create(:venue, owner: user)
      end
    end
    
    trait :as_venue_admin do
      transient do
        admin_venue { nil }
      end
      
      after(:create) do |user, evaluator|
        admin_venue = evaluator.admin_venue || create(:venue)
        admin_venue.add_admin(user)
      end
    end
    
    trait :with_oauth do
      provider { 'google_oauth2' }
      uid { Faker::Number.unique.number(digits: 10).to_s }
    end
  end
end
