# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe EventQueueRuntimePolicy, type: :service do
  let(:venue) { create(:venue) }
  let(:event) { create(:event, venue: venue, status: :live, starts_at: 1.hour.ago, ends_at: 10.minutes.from_now) }

  it 'allows a queue that completes before the event end' do
    candidate = build(:song, venue: venue, event: event, effective_duration_seconds: 180)

    result = described_class.call(event: event, candidate: candidate)

    expect(result).to be_allowed
    expect(result.projected_completion_at).to be <= event.ends_at
  end

  it 'rejects a queue that would exceed the event end' do
    event.update!(ends_at: 2.minutes.from_now)
    candidate = build(:song, venue: venue, event: event, effective_duration_seconds: 180)

    result = described_class.call(event: event, candidate: candidate)

    expect(result).not_to be_allowed
    expect(result.reason).to include('beyond the event end')
  end

  it 'includes existing queued songs and excludes skipped songs' do
    create(:song, venue: venue, event: event, effective_duration_seconds: 300)
    create(:song, venue: venue, event: event, effective_duration_seconds: 300, skipped: true)
    candidate = build(:song, venue: venue, event: event, effective_duration_seconds: 180)
    event.update!(ends_at: 5.minutes.from_now)

    result = described_class.call(event: event, candidate: candidate)

    expect(result).not_to be_allowed
  end

  it 'allows an explicit audited overrun setting' do
    event.update!(allow_queue_overrun: true)
    candidate = build(:song, venue: venue, event: event, effective_duration_seconds: 180)
    event.update!(ends_at: 1.minute.from_now)

    expect(described_class.call(event: event, candidate: candidate)).to be_allowed
  end

  it 'uses the safe duration fallback for a candidate without a snapshot' do
    candidate = build(:song, venue: venue, event: event, effective_duration_seconds: nil)
    at = Time.current

    result = described_class.call(event: event, candidate: candidate, at: at)

    expect(result.projected_completion_at).to eq(at + Song::DEFAULT_DURATION_SECONDS + 30)
  end
end
# rubocop:enable Metrics/BlockLength
