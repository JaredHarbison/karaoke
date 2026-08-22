FactoryBot.define do
  factory :performance do
    performer { Faker::Name.name }
    url { "https://www.youtube.com/watch?v=#{Faker::Alphanumeric.alphanumeric(number: 11)}" }
    association :venue
    association :user
    
    finished { false }
    skipped { false }
    postponed { false }
    
    trait :finished do
      finished { true }
    end
    
    trait :skipped do
      skipped { true }
    end
    
    trait :postponed do
      postponed { true }
    end
    
    trait :queued do
      finished { false }
      skipped { false }
      postponed { false }
    end
    
    trait :with_random_state do
      before(:create) do |song|
        state = %i[finished skipped postponed queued].sample
        case state
        when :finished
          song.finished = true
        when :skipped
          song.skipped = true
        when :postponed
          song.postponed = true
        end
      end
    end
  end

  factory :song, parent: :performance
end
