# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe SongQueue::Reorder, type: :service do
  it 'keeps host reordering scoped to the song event' do
    event = create(:event)
    other_event = create(:event)
    first = create(:song, event: event, venue: event.venue, updated_at: 2.hours.ago)
    target = create(:song, event: event, venue: event.venue, updated_at: 1.hour.ago)
    other = create(:song, event: other_event, venue: other_event.venue, updated_at: 3.hours.ago)

    host = event.venue.owner
    described_class.pause!(target, 1, actor: host)

    expect(Song.unscoped.where(event_id: event.id).order(:updated_at).pluck(:id)).to eq([first.id, target.id])
    expect(other.reload.postponed).to be(false)
    expect(SongQueueOverride.last).to have_attributes(
      event: event, song: target, user: host, action: 'pause', spots_back: 1
    )
  end

  it 'locks the event while reordering an event queue' do
    event = create(:event)
    song = create(:song, event: event, venue: event.venue)
    expect(event).to receive(:with_lock).and_call_original

    described_class.pause!(song, 1, actor: event.venue.owner)
  end

  it 'keeps simultaneous event reorders consistent', use_transactional_fixtures: false do
    venue = create(:venue)
    event = create(:event, venue: venue)
    first = create(:song, event: event, venue: venue, updated_at: 2.hours.ago)
    second = create(:song, event: event, venue: venue, updated_at: 1.hour.ago)
    host_id = venue.owner_id

    run_concurrently([first.id, second.id]) do |song_id|
      described_class.pause!(Song.find(song_id), 1, actor: User.find(host_id))
    end

    queue_ids = Song.unscoped.where(event_id: event.id).order(:updated_at, :id).pluck(:id)
    expect(queue_ids).to match_array([first.id, second.id])
    expect(event.song_queue_overrides.count).to eq(2)
  ensure
    SongQueueOverride.where(event_id: event&.id).delete_all
    venue&.destroy!
  end
end
# rubocop:enable Metrics/BlockLength
