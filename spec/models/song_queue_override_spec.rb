# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SongQueueOverride, type: :model do
  it 'requires the song to belong to the recorded event' do
    event = create(:event)
    other_event = create(:event, venue: event.venue)
    song = create(:performance, event: other_event, venue: event.venue)

    override = described_class.new(event: event, song: song, user: event.venue.owner, action: 'pause')

    expect(override).not_to be_valid
    expect(override.errors[:song]).to include('must belong to the same event')
  end
end
