# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventPresenceAttemptRetention, type: :service do
  it 'removes records older than the retention window' do
    stale = EventPresenceAttempt.create!(
      fingerprint: 'stale-client',
      window_started_at: 2.days.ago,
      attempts: 1
    )
    current = EventPresenceAttempt.create!(
      fingerprint: 'current-client',
      window_started_at: 1.hour.ago,
      attempts: 1
    )

    expect { described_class.prune! }.to change(EventPresenceAttempt, :count).by(-1)
    expect(EventPresenceAttempt.exists?(stale.id)).to be(false)
    expect(EventPresenceAttempt.exists?(current.id)).to be(true)
  end

  it 'allows a caller to provide an explicit cutoff' do
    old = EventPresenceAttempt.create!(
      fingerprint: 'old-client',
      window_started_at: 2.hours.ago,
      attempts: 1
    )

    expect(described_class.prune!(before: 1.hour.ago)).to eq(1)
    expect(EventPresenceAttempt.exists?(old.id)).to be(false)
  end
end
