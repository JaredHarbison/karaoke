FactoryBot.define do
  factory :venue do
    sequence(:name) { |n| "#{Faker::Restaurant.name} #{n}" }
    association :owner, factory: :user, role: :owner
    public { true }
    
    trait :private do
      public { false }
    end
    
    trait :public do
      public { true }
    end
    
    trait :with_admins do
      transient do
        admin_count { 2 }
      end
      
      after(:create) do |venue, evaluator|
        evaluator.admin_count.times do
          admin = create(:user, role: :admin)
          venue.add_admin(admin)
        end
      end
    end
    
    trait :with_songs do
      transient do
        song_count { 3 }
      end
      
      after(:create) do |venue, evaluator|
        evaluator.song_count.times do
          create(:song, venue: venue)
        end
      end
    end
    
    trait :with_performers do
      transient do
        performer_count { 5 }
      end
      
      after(:create) do |venue, evaluator|
        evaluator.performer_count.times do
          create(:user, role: :performer, venue: venue)
        end
      end
    end
  end
end
