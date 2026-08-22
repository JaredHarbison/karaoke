# Canonical provider-backed song identity shared by event performances.
class Song < ApplicationRecord
  self.table_name = 'song_identities'

  has_many :performances, foreign_key: :song_identity_id, dependent: :nullify

  validates :provider, :provider_video_id, presence: true
  validates :provider_video_id, uniqueness: { scope: :provider }
end
