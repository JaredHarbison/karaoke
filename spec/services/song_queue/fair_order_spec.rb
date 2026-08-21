# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SongQueue::FairOrder, type: :service do
  it 'favors performers with fewer completed event turns' do
    event = create(:event)
    create(:song, :finished, event: event, venue: event.venue, performer: 'Repeat Singer')
    first = create(:song, event: event, venue: event.venue, performer: 'Repeat Singer', updated_at: 2.hours.ago)
    second = create(:song, event: event, venue: event.venue, performer: 'New Singer', updated_at: 1.hour.ago)

    result = described_class.new(Song.where(id: [first.id, second.id]), event: event).call

    expect(result).to eq([second, first])
  end

  it 'uses stable queue position to break equal fairness scores' do
    event = create(:event)
    first = create(:song, event: event, venue: event.venue, performer: 'First Singer', updated_at: 2.hours.ago)
    second = create(:song, event: event, venue: event.venue, performer: 'Second Singer', updated_at: 1.hour.ago)

    result = described_class.new(Song.where(id: [second.id, first.id]), event: event).call

    expect(result).to eq([first, second])
  end

  it 'keeps a performer from taking consecutive turns before another performer' do
    event = create(:event)
    first = create(:song, event: event, venue: event.venue, performer: 'Singer One', updated_at: 3.hours.ago)
    second = create(:song, event: event, venue: event.venue, performer: 'Singer One', updated_at: 2.hours.ago)
    third = create(:song, event: event, venue: event.venue, performer: 'Singer Two', updated_at: 1.hour.ago)

    result = described_class.new(Song.where(id: [first.id, second.id, third.id]), event: event).call

    expect(result).to eq([first, third, second])
  end
end
