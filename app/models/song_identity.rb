# frozen_string_literal: true

# Canonical provider-backed song identity shared by future event performances.
class SongIdentity < ApplicationRecord
  has_many :queue_songs, class_name: 'Song', dependent: :nullify

  validates :provider, :provider_video_id, presence: true
  validates :provider_video_id, uniqueness: { scope: :provider }
end
