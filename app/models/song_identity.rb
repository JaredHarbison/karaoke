# frozen_string_literal: true

# Canonical provider-backed song identity shared by future event performances.
class SongIdentity < ApplicationRecord
  has_many :performances, dependent: :nullify
  alias queue_songs performances

  validates :provider, :provider_video_id, presence: true
  validates :provider_video_id, uniqueness: { scope: :provider }
end
