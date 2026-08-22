# frozen_string_literal: true

FactoryBot.define do
  factory :song_identity do
    provider { 'youtube' }
    provider_video_id { Faker::Alphanumeric.alphanumeric(number: 11) }
    title { 'Karaoke Video' }
    verified_karaoke { true }
    explicit_lyrics { false }
    duration_seconds { 180 }
    metadata_checked_at { Time.current }
  end
end
