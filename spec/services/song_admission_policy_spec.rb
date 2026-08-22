# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe SongAdmissionPolicy, type: :service do
  let(:venue) { create(:venue) }
  let(:event) { create(:event, venue: venue) }

  def metadata(overrides = {})
    { video_id: 'video-1', verified_karaoke: true, explicit_lyrics: false, duration_seconds: 180 }.merge(overrides)
  end

  before do
    allow(YoutubeService).to receive(:validate_karaoke_video).and_return(metadata)
  end

  it 'admits eligible metadata and snapshots provider duration' do
    song = build(:song, venue: venue, event: event)

    result = described_class.call(song: song, venue: venue)

    expect(result).to be_eligible
    expect(song).to have_attributes(
      metadata_status: 'eligible', provider_video_id: 'video-1', duration_seconds: 180,
      effective_duration_seconds: 180, duration_source: 'provider'
    )
  end

  it 'reuses validated catalog metadata without calling the provider again' do
    create(
      :song,
      venue: venue,
      provider: 'youtube',
      provider_video_id: 'video-1',
      metadata_status: 'eligible',
      explicit_lyrics: false,
      duration_seconds: 180,
      metadata_checked_at: 1.hour.ago,
      title: 'Cached Karaoke Video'
    )
    expect(YoutubeService).not_to receive(:validate_karaoke_video)
    song = build(:song, venue: venue, event: event, url: 'https://youtube.com/watch?v=video-1')

    result = described_class.call(song: song, venue: venue)

    expect(result).to be_eligible
    expect(song.title).to eq('Cached Karaoke Video')
    expect(song.duration_source).to eq('provider')
  end

  it 'uses the average of known durations when provider duration is missing' do
    create(:song, venue: venue, event: event, duration_seconds: 120, effective_duration_seconds: 120)
    create(:song, venue: venue, event: event, duration_seconds: 240, effective_duration_seconds: 240)
    create(:song, venue: venue, event: event, duration_seconds: nil, effective_duration_seconds: 900)
    allow(YoutubeService).to receive(:validate_karaoke_video).and_return(metadata(duration_seconds: nil))
    song = build(:song, venue: venue, event: event)

    described_class.call(song: song, venue: venue)

    expect(song).to have_attributes(effective_duration_seconds: 180, duration_source: 'average')
  end

  it 'uses a safe fallback when no known duration exists' do
    allow(YoutubeService).to receive(:validate_karaoke_video).and_return(metadata(duration_seconds: nil))
    song = build(:song, venue: venue, event: event)

    described_class.call(song: song, venue: venue)

    expect(song).to have_attributes(
      effective_duration_seconds: Song::DEFAULT_DURATION_SECONDS,
      duration_source: 'fallback'
    )
  end

  it 'holds unknown provider metadata for review' do
    allow(YoutubeService).to receive(:validate_karaoke_video).and_return({ error: 'provider unavailable' })
    song = build(:song, venue: venue, event: event)

    result = described_class.call(song: song, venue: venue)

    expect(result.status).to eq(:review)
    expect(song.metadata_status).to eq('review')
  end

  it 'holds explicit metadata for content-policy review during a theme' do
    event.update!(starts_at: 1.hour.ago)
    theme = create(:theme, venue: venue, rules: { 'required_keywords' => ['disco'] })
    create(:event_theme_application, event: event, theme: theme)
    allow(YoutubeService).to receive(:validate_karaoke_video).and_return(metadata(explicit_lyrics: true))
    song = build(:song, venue: venue, event: event)

    result = described_class.call(song: song, venue: venue)

    expect(result).to be_saveable
    expect(result.status).to eq(:review)
    expect(result.reason).to match(/content policy:.*explicit lyrics/)
    expect(song.theme_admission_status).to eq('review')
  end

  it 'hard-rejects explicit metadata outside a theme' do
    allow(YoutubeService).to receive(:validate_karaoke_video).and_return(metadata(explicit_lyrics: true))
    song = build(:song, venue: venue, event: event)

    result = described_class.call(song: song, venue: venue)

    expect(result).not_to be_saveable
    expect(result.status).to eq(:rejected)
  end

  it 'allows explicit metadata when the venue permits it' do
    venue.update!(explicit_lyrics_allowed: true)
    allow(YoutubeService).to receive(:validate_karaoke_video).and_return(metadata(explicit_lyrics: true))
    song = build(:song, venue: venue, event: event)

    result = described_class.call(song: song, venue: venue)

    expect(result).to be_eligible
  end
end
# rubocop:enable Metrics/BlockLength
