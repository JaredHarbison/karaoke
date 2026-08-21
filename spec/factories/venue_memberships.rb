# frozen_string_literal: true

FactoryBot.define do
  factory :venue_membership do
    association :venue
    association :user
    role { :performer }

    trait :owner do
      role { :owner }
    end

    trait :admin do
      role { :admin }
    end
  end
end
