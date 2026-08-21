# frozen_string_literal: true

FactoryBot.define do
  factory :event_series do
    association :venue
    name { 'Friday Karaoke' }
    recurrence_rule { 'FREQ=WEEKLY;BYDAY=FR' }
    starts_at { 1.week.from_now.change(hour: 20, min: 0) }
    ends_at { 1.week.from_now.change(hour: 23, min: 0) }
    time_zone { 'America/New_York' }
    active { true }
  end
end
