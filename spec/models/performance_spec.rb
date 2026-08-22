# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Performance, type: :model do
  it 'uses the existing queue table as the event-specific record' do
    performance = create(:performance, event: nil)

    expect(performance).to be_a(Performance)
    expect(Performance.find(performance.id)).to be_a(Performance)
    expect(Performance.table_name).to eq('songs')
  end

  it 'links each event queue entry to one canonical song identity' do
    identity = create(:canonical_song, provider_video_id: 'performance-video')
    performance = create(:performance, song_identity: identity)

    expect(performance.song).to eq(identity)
    expect(identity.performances.map(&:id)).to contain_exactly(performance.id)
  end
end
