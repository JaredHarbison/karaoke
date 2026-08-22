# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Performance, type: :model do
  it 'uses the existing queue table while Song remains a compatibility name' do
    performance = create(:song, event: nil)

    expect(performance).to be_a(Song)
    expect(Performance.find(performance.id)).to be_a(Performance)
    expect(Song < Performance).to be(true)
  end

  it 'links each event queue entry to one canonical song identity' do
    identity = create(:song_identity, provider_video_id: 'performance-video')
    performance = create(:song, song_identity: identity)

    expect(identity.performances.map(&:id)).to contain_exactly(performance.id)
  end
end
