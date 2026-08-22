# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe EventPresenceSession, type: :model do
  it 'generates an active session for an authorized host within the event window' do
    event = create(:event, starts_at: 1.hour.from_now, ends_at: 3.hours.from_now)
    session = described_class.new(event: event, created_by_user: event.venue.owner, expires_at: event.ends_at)

    expect(session).to be_valid
    expect(session.token).to be_present
    expect(session.short_code).to match(/\A[A-Z0-9]{6}\z/)
    expect(session.active_at?(event.starts_at + 1.hour)).to be(true)
  end

  it 'allows the configured grace period after the event ends' do
    event = create(:event)
    session = described_class.new(
      event: event, created_by_user: event.venue.owner,
      expires_at: event.ends_at + EventPresenceSession::GRACE_PERIOD
    )

    expect(session).to be_valid
  end

  it 'rejects an expiry beyond the configured grace period' do
    event = create(:event)
    session = described_class.new(
      event: event, created_by_user: event.venue.owner,
      expires_at: event.ends_at + EventPresenceSession::GRACE_PERIOD + 1.minute
    )

    expect(session).not_to be_valid
  end

  it 'generates readable codes without ambiguous characters' do
    session = build(:event_presence_session)
    session.valid?

    expect(session.short_code).to match(/\A[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{6}\z/)
  end
end
# rubocop:enable Metrics/BlockLength
