# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventHostDelegation, type: :model do
  it 'allows an active delegation only within the event window' do
    event = create(:event, starts_at: 1.hour.from_now, ends_at: 3.hours.from_now)
    host = event.venue.owner
    performer = create(:user)
    event.venue.venue_memberships.create!(user: performer, role: :performer)
    delegation = described_class.new(event: event, delegated_user: performer, delegated_by_user: host,
                                     starts_at: event.starts_at, ends_at: event.ends_at)

    expect(delegation).to be_valid
    expect(delegation.active_at?(event.starts_at + 1.hour)).to be(true)
  end

  it 'rejects a delegation outside the event window' do
    event = create(:event)
    performer = create(:user)
    event.venue.venue_memberships.create!(user: performer, role: :performer)
    delegation = described_class.new(event: event, delegated_user: performer, delegated_by_user: event.venue.owner,
                                     starts_at: event.starts_at - 1.hour, ends_at: event.ends_at)

    expect(delegation).not_to be_valid
  end
end
