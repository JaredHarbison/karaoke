# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe SongQueue::FairOrder, type: :service do
  it 'favors performers with fewer completed event turns' do
    event = create(:event)
    create(:performance, :finished, event: event, venue: event.venue, performer: 'Repeat Singer')
    first = create(:performance, event: event, venue: event.venue, performer: 'Repeat Singer', updated_at: 2.hours.ago)
    second = create(:performance, event: event, venue: event.venue, performer: 'New Singer', updated_at: 1.hour.ago)

    result = described_class.new(Performance.where(id: [first.id, second.id]), event: event).call

    expect(result).to eq([second, first])
  end

  it 'uses stable queue position to break equal fairness scores' do
    event = create(:event)
    first = create(:performance, event: event, venue: event.venue, performer: 'First Singer', updated_at: 2.hours.ago)
    second = create(:performance, event: event, venue: event.venue, performer: 'Second Singer', updated_at: 1.hour.ago)

    result = described_class.new(Performance.where(id: [second.id, first.id]), event: event).call

    expect(result).to eq([first, second])
  end

  it 'keeps a performer from taking consecutive turns before another performer' do
    event = create(:event)
    first = create(:performance, event: event, venue: event.venue, performer: 'Singer One', updated_at: 3.hours.ago)
    second = create(:performance, event: event, venue: event.venue, performer: 'Singer One', updated_at: 2.hours.ago)
    third = create(:performance, event: event, venue: event.venue, performer: 'Singer Two', updated_at: 1.hour.ago)

    result = described_class.new(Performance.where(id: [first.id, second.id, third.id]), event: event).call

    expect(result).to eq([first, third, second])
  end

  it 'uses user identity rather than display name when available' do
    event = create(:event)
    user = create(:user)
    create(:performance, :finished, event: event, venue: event.venue, user: user, performer: 'Stage Name')
    queued = create(:performance, event: event, venue: event.venue, user: user,
                                  performer: 'Different Label',
                                  updated_at: 2.hours.ago)
    new_singer = create(:performance, event: event, venue: event.venue,
                                      performer: 'New Singer',
                                      updated_at: 1.hour.ago)

    result = described_class.new(Performance.where(id: [queued.id, new_singer.id]), event: event).call

    expect(result).to eq([new_singer, queued])
  end

  it 'does not count skipped songs as completed turns' do
    event = create(:event)
    create(:performance, :finished, :skipped, event: event, venue: event.venue, performer: 'Skipped Singer')
    skipped_singer = create(:performance, event: event, venue: event.venue,
                                          performer: 'Skipped Singer', updated_at: 2.hours.ago)
    new_singer = create(:performance, event: event, venue: event.venue, performer: 'New Singer', updated_at: 1.hour.ago)

    result = described_class.new(Performance.where(id: [skipped_singer.id, new_singer.id]), event: event).call

    expect(result).to eq([skipped_singer, new_singer])
  end
end
# rubocop:enable Metrics/BlockLength
