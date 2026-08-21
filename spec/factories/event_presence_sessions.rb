# frozen_string_literal: true

FactoryBot.define do
  factory :event_presence_session do
    association :event
    created_by_user { event.venue.owner }
    expires_at { event.ends_at }
  end
end
