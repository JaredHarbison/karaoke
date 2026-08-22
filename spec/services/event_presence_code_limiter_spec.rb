# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventPresenceCodeLimiter, type: :service do
  let(:fingerprint) { 'hashed-client-address' }

  it 'allows ten attempts and blocks the eleventh in one window' do
    results = 11.times.map { described_class.allow?(fingerprint: fingerprint) }

    expect(results.last).to be(false)
    expect(results.first(10)).to all(be(true))
    expect(EventPresenceAttempt.last.attempts).to eq(10)
  end

  it 'starts a fresh counter in the next window' do
    now = Time.zone.parse('2026-08-22 20:00:00')
    10.times { described_class.allow?(fingerprint: fingerprint, now: now) }

    expect(described_class.allow?(fingerprint: fingerprint, now: now + 1.minute)).to be(true)
    expect(EventPresenceAttempt.count).to eq(2)
  end
end
