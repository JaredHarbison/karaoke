# frozen_string_literal: true

# Stores one canonical provider identity independently from event queue entries.
class CreateSongIdentities < ActiveRecord::Migration[7.2]
  def change
    create_song_identities_table
    add_song_identity_indexes
    add_song_identity_reference
  end

  private

  def create_song_identities_table
    create_table :song_identities do |t|
      t.string :provider, null: false, default: 'youtube'
      t.string :provider_video_id, null: false
      t.string :title
      t.boolean :verified_karaoke, null: false, default: false
      t.boolean :explicit_lyrics
      t.integer :duration_seconds
      t.datetime :metadata_checked_at
      t.timestamps
    end
  end

  def add_song_identity_indexes
    add_index :song_identities, %i[provider provider_video_id], unique: true
  end

  def add_song_identity_reference
    add_reference :songs, :song_identity, foreign_key: true
  end
end
