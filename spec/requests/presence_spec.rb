# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Presence access', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:venue) { create(:venue) }
  let(:owner) { venue.owner }

  it 'resolves a permanent venue presence URL' do
    get venue_presence_path(venue.presence_token)

    expect(response).to redirect_to(venue_songs_path(venue.slug))
  end

  it 'resolves an active event presence URL' do
    event = create(:event, venue: venue)
    presence = create(:event_presence_session, event: event, created_by_user: owner, expires_at: event.ends_at)

    get event_presence_path(presence.token)

    expect(response).to redirect_to(venue_songs_path(venue.slug, event_id: event.id))
  end

  it 'resolves an active event presence short code case-insensitively' do
    event = create(:event, venue: venue)
    presence = create(:event_presence_session, event: event, created_by_user: owner, expires_at: event.ends_at)

    get event_presence_code_path(short_code: presence.short_code.downcase)

    expect(response).to redirect_to(venue_songs_path(venue.slug, event_id: event.id))
  end

  it 'rejects an expired event presence short code' do
    event = create(:event, venue: venue)
    presence = create(:event_presence_session, event: event, created_by_user: owner, expires_at: 1.minute.ago)

    get event_presence_code_path(short_code: presence.short_code)

    expect(response).to redirect_to(discover_venues_path)
  end

  it 'rejects expired event presence URLs' do
    event = create(:event, venue: venue)
    presence = create(:event_presence_session, event: event, created_by_user: owner, expires_at: 1.minute.ago)

    get event_presence_path(presence.token)

    expect(response).to redirect_to(discover_venues_path)
  end

  it 'allows a host to generate an event presence session' do
    event = create(:event, venue: venue)
    sign_in owner

    expect do
      post venue_event_presence_sessions_path(venue.slug), params: { event_id: event.id }
    end.to change(EventPresenceSession, :count).by(1)

    expect(EventPresenceSession.last.short_code).to match(/\A[A-Z0-9]{6}\z/)
    expect(response).to redirect_to(venue_event_path(venue.slug, event))
  end
end
# rubocop:enable Metrics/BlockLength
