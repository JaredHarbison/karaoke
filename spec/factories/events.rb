# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    association :venue
    name { 'Friday Karaoke' }
    starts_at { 1.week.from_now.change(hour: 20, min: 0) }
    ends_at { 1.week.from_now.change(hour: 23, min: 0) }
    status { :scheduled }

    trait :from_series do
      association :event_series
    end
  end
end
