# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YoutubeVideoPolicy, type: :service do
  it 'admits only verified karaoke metadata with known clean lyrics' do
    result = described_class.call(
      video: { verified_karaoke: true, explicit_lyrics: false },
      explicit_lyrics_allowed: false
    )

    expect(result).to have_attributes(status: :eligible)
  end

  it 'rejects explicit lyrics when the venue disallows them' do
    result = described_class.call(
      video: { verified_karaoke: true, explicit_lyrics: true },
      explicit_lyrics_allowed: false
    )

    expect(result).to have_attributes(status: :rejected, reason: /explicit lyrics/)
  end

  it 'allows explicit lyrics when the venue permits them' do
    result = described_class.call(
      video: { verified_karaoke: true, explicit_lyrics: true },
      explicit_lyrics_allowed: true
    )

    expect(result).to have_attributes(status: :eligible)
  end

  it 'reviews unknown karaoke or lyrics metadata instead of admitting it' do
    expect(described_class.call(video: {}, explicit_lyrics_allowed: false).status).to eq(:review)
  end
end
