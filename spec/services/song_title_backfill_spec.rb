# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SongTitleBackfill, type: :service do
  it 'fills only missing titles from valid provider metadata' do
    untitled = create(:performance, title: nil, url: 'https://youtube.com/watch?v=untitled')
    titled = create(:performance, title: 'Existing title', url: 'https://youtube.com/watch?v=titled')
    allow(YoutubeService).to receive(:validate_karaoke_video).and_return(valid: true, title: nil)
    allow(YoutubeService).to receive(:validate_karaoke_video).with(untitled.url).and_return(
      { valid: true, title: 'Recovered Song' }
    )

    result = described_class.call(scope: Performance.unscoped.where(id: [untitled.id, titled.id]))

    expect(result).to have_attributes(scanned: 1, updated: 1, skipped: 0)
    expect(untitled.reload.title).to eq('Recovered Song')
    expect(titled.reload.title).to eq('Existing title')
  end

  it 'skips provider responses without a valid title' do
    song = create(:performance, title: nil, url: 'https://youtube.com/watch?v=missing')
    allow(YoutubeService).to receive(:validate_karaoke_video).with(song.url).and_return(
      { valid: false, error: 'Video not found' }
    )

    result = described_class.call(scope: Performance.unscoped.where(id: song.id))

    expect(result).to have_attributes(scanned: 1, updated: 0, skipped: 1)
    expect(song.reload.title).to be_nil
  end
end
