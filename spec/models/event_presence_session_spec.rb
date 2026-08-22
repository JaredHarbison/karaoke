# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventPresenceSession, type: :model do
  it 'generates an active session for an authorized host within the event window' do
    event = create(:event, starts_at: 1.hour.from_now, ends_at: 3.hours.from_now)
    session = described_class.new(event: event, created_by_user: event.venue.owner, expires_at: event.ends_at)

    expect(session).to be_valid
    expect(session.token).to be_present
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
end
