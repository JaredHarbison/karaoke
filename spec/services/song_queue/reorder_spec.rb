# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SongQueue::Reorder, type: :service do
  it 'keeps host reordering scoped to the song event' do
    event = create(:event)
    other_event = create(:event)
    first = create(:song, event: event, updated_at: 2.hours.ago)
    target = create(:song, event: event, updated_at: 1.hour.ago)
    other = create(:song, event: other_event, updated_at: 3.hours.ago)

    described_class.pause!(target, 1)

    expect(Song.unscoped.where(event_id: event.id).order(:updated_at).pluck(:id)).to eq([first.id, target.id])
    expect(other.reload.postponed).to be(false)
  end
end
