# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Events', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:venue) { create(:venue) }
  let(:owner) { venue.owner }
  let(:host) { create(:user) }
  let(:performer) { create(:user) }

  before do
    venue.add_host(host)
  end

  describe 'GET /:venue_slug/events' do
    it 'lets an authenticated user view venue events', :critical do
      sign_in performer
      create(:event, venue: venue)

      get venue_events_path(venue.slug)

      expect(response).to be_successful
      expect(response.body).to include('Events', 'Friday Karaoke')
    end

    it 'requires authentication' do
      get venue_events_path(venue.slug)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'POST /:venue_slug/events' do
    let(:event_attributes) do
      {
        name: 'Saturday Karaoke',
        starts_at: 2.days.from_now,
        ends_at: 2.days.from_now + 3.hours
      }
    end

    it 'allows a venue host to create an event', :critical do
      sign_in host

      expect do
        post venue_events_path(venue.slug), params: { event: event_attributes }
      end.to change(Event, :count).by(1)

      expect(response).to redirect_to(venue_event_path(venue.slug, Event.last))
    end

    it 'denies event creation to performers' do
      sign_in performer

      expect do
        post venue_events_path(venue.slug), params: { event: event_attributes }
      end.not_to change(Event, :count)

      expect(response).to redirect_to(venue_songs_path(venue.slug))
    end
  end

  describe 'event occurrence editing' do
    it 'allows an occurrence to change without changing its series', :critical do
      series = create(:event_series, venue: venue)
      event = create(:event, venue: venue, event_series: series)
      sign_in host

      patch venue_event_path(venue.slug, event), params: {
        event: { name: 'Holiday Karaoke', starts_at: event.starts_at + 1.day, ends_at: event.ends_at + 1.day }
      }

      expect(response).to redirect_to(venue_event_path(venue.slug, event))
      expect(event.reload.name).to eq('Holiday Karaoke')
      expect(series.reload.name).to eq('Friday Karaoke')
    end

    it 'allows a host to configure the event queue mode' do
      event = create(:event, venue: venue)
      sign_in host

      patch venue_event_path(venue.slug, event), params: { event: { fair_queue_enabled: false } }

      expect(response).to redirect_to(venue_event_path(venue.slug, event))
      expect(event.reload.fair_queue_enabled).to be(false)
    end
  end

  describe 'temporary host delegation' do
    it 'lets a venue host delegate event queue authority to a venue member' do
      event = create(:event, venue: venue, starts_at: 1.hour.from_now, ends_at: 3.hours.from_now)
      delegated_host = create(:user)
      venue.venue_memberships.create!(user: delegated_host, role: :performer)
      sign_in owner

      expect do
        post venue_event_host_delegations_path(venue.slug), params: {
          event_id: event.id,
          event_host_delegation: {
            delegated_user_id: delegated_host.id,
            starts_at: event.starts_at,
            ends_at: event.ends_at
          }
        }
      end.to change(EventHostDelegation, :count).by(1)

      expect(response).to redirect_to(venue_event_path(venue.slug, event))
      expect(EventHostDelegation.last.delegated_user).to eq(delegated_host)
    end

    it 'does not allow a performer to create a delegation' do
      event = create(:event, venue: venue)
      sign_in performer

      post venue_event_host_delegations_path(venue.slug), params: { event_id: event.id }

      expect(response).to redirect_to(venue_songs_path(venue.slug))
    end
  end

  describe 'recurring series management' do
    it 'allows a venue owner to create a series', :critical do
      sign_in owner

      expect do
        post venue_event_series_index_path(venue.slug), params: {
          event_series: attributes_for(:event_series).except(:venue_id)
        }
      end.to change(EventSeries, :count).by(1)

      expect(response).to redirect_to(venue_event_series_index_path(venue.slug))
    end

    it 'denies series management to performers' do
      sign_in performer

      get venue_event_series_index_path(venue.slug)

      expect(response).to redirect_to(venue_songs_path(venue.slug))
    end
  end
end
# rubocop:enable Metrics/BlockLength
