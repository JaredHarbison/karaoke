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

    expect(response).to redirect_to(venue_event_queue_path(venue.slug, event_slug: event.slug))
  end

  it 'resolves an active event presence short code case-insensitively' do
    event = create(:event, venue: venue)
    presence = create(:event_presence_session, event: event, created_by_user: owner, expires_at: event.ends_at)

    get event_presence_code_path(short_code: presence.short_code.downcase)

    expect(response).to redirect_to(venue_event_queue_path(venue.slug, event_slug: event.slug))
  end

  it 'accepts readable spacing and hyphen formatting for an event code' do
    event = create(:event, venue: venue)
    presence = create(:event_presence_session, event: event, created_by_user: owner, expires_at: event.ends_at)
    formatted_code = presence.short_code.insert(3, '-').downcase

    get event_presence_code_path(short_code: formatted_code)

    expect(response).to redirect_to(venue_event_queue_path(venue.slug, event_slug: event.slug))
  end

  it 'rejects an expired event presence short code' do
    event = create(:event, venue: venue)
    presence = create(:event_presence_session, event: event, created_by_user: owner, expires_at: 1.minute.ago)

    get event_presence_code_path(short_code: presence.short_code)

    expect(response).to redirect_to(root_path)
  end

  it 'rejects expired event presence URLs' do
    event = create(:event, venue: venue)
    presence = create(:event_presence_session, event: event, created_by_user: owner, expires_at: 1.minute.ago)

    get event_presence_path(presence.token)

    expect(response).to redirect_to(root_path)
  end

  it 'limits repeated invalid event access-code attempts' do
    10.times do
      get event_presence_code_path(short_code: 'INVALID')
    end

    get event_presence_code_path(short_code: 'INVALID')

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to include('Too many access-code attempts')
  end

  it 'allows a host to generate an event presence session' do
    event = create(:event, venue: venue)
    sign_in owner

    expect do
      post venue_event_presence_sessions_path(venue.slug), params: { event_id: event.id }
    end.to change(EventPresenceSession, :count).by(1)

    expect(EventPresenceSession.last.short_code).to match(/\A[A-Z0-9]{6}\z/)
    expect(response).to redirect_to(venue_event_queue_path(venue.slug, event_slug: event.slug))
  end

  it 'rotates the active event access session when a host generates a replacement' do
    event = create(:event, venue: venue, status: :live)
    previous = create(:event_presence_session, event: event, created_by_user: owner, expires_at: event.ends_at)
    sign_in owner

    post venue_event_presence_sessions_path(venue.slug), params: { event_id: event.id }

    replacement = event.event_presence_sessions.order(:created_at).last
    expect(previous.reload.revoked_at).to be_present
    expect(replacement).to be_active_at

    get event_presence_path(previous.token)
    expect(response).to redirect_to(root_path)
  end
end
# rubocop:enable Metrics/BlockLength
