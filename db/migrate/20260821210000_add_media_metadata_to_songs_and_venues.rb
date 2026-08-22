# frozen_string_literal: true

# Adds provider policy and duration snapshots without requiring the Performance
# migration.
class AddMediaMetadataToSongsAndVenues < ActiveRecord::Migration[7.2]
  def change
    add_column :venues, :explicit_lyrics_allowed, :boolean, null: false, default: false

    add_column :songs, :provider, :string, null: false, default: 'youtube'
    add_column :songs, :provider_video_id, :string
    add_column :songs, :metadata_status, :string, null: false, default: 'legacy'
    add_column :songs, :explicit_lyrics, :boolean
    add_column :songs, :duration_seconds, :integer
    add_column :songs, :effective_duration_seconds, :integer
    add_column :songs, :duration_source, :string
    add_column :songs, :metadata_checked_at, :datetime

    add_index :songs, %i[provider provider_video_id]
  end
end
