# frozen_string_literal: true

FactoryBot.define do
  factory :event_theme_application do
    association :event
    theme { association(:theme, venue: event.venue) }
    starts_at { event.starts_at }
    ends_at { event.ends_at }
  end
end
