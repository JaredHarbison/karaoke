# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe SongCatalog, type: :service do
  it 'returns validated metadata for an existing eligible YouTube selection' do
    song = create(
      :song,
      provider: 'youtube',
      provider_video_id: 'video-1',
      metadata_status: 'eligible',
      explicit_lyrics: false,
      duration_seconds: 210,
      metadata_checked_at: 1.hour.ago,
      title: 'Existing Karaoke Video'
    )

    expect(described_class.metadata_for('https://youtube.com/watch?v=video-1')).to include(
      valid: true,
      video_id: song.provider_video_id,
      title: song.title,
      verified_karaoke: true,
      explicit_lyrics: false,
      duration_seconds: 210
    )
  end

  it 'does not reuse rejected or unverified provider metadata' do
    create(:song, provider: 'youtube', provider_video_id: 'video-2', metadata_status: 'rejected')
    create(:song, provider: 'youtube', provider_video_id: 'video-3', metadata_status: 'review')

    expect(described_class.metadata_for('https://youtube.com/watch?v=video-2')).to be_nil
    expect(described_class.metadata_for('https://youtube.com/watch?v=video-3')).to be_nil
  end
end
# rubocop:enable Metrics/BlockLength
