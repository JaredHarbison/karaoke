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
      expect(response.body).to include('Events', 'Friday Karaoke', 'Performer Menu', 'Skip to main content')
      expect(response.body).not_to include('Venue menu')
    end

    it 'requires authentication' do
      get venue_events_path(venue.slug)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'GET /:venue_slug/events/:id' do
    it 'creates an access code when an owner opens a live event with none' do
      event = create(:event, venue: venue, status: :live, starts_at: 1.hour.ago)
      sign_in owner

      expect do
        get venue_event_path(venue.slug, event)
      end.to change { event.event_presence_sessions.active_at.count }.from(0).to(1)

      expect(response.body).to include('Event access code:')
    end

    it 'shows the active performer access code without exposing stale codes' do
      event = create(:event, venue: venue, status: :live)
      active_session = create(:event_presence_session, event: event, created_by_user: owner, expires_at: event.ends_at)
      stale_session = create(:event_presence_session, event: event, created_by_user: owner, expires_at: event.ends_at)
      stale_session.update!(revoked_at: Time.current)
      sign_in owner

      get venue_event_path(venue.slug, event)

      expect(response).to be_successful
      expect(response.body).to include("Event access code: #{active_session.short_code}", 'Access-code history')
      expect(response.body).not_to include(event_presence_url(stale_session.token))
    end
  end

  describe 'GET /:venue_slug/events/:slug/queue' do
    it 'puts manager theme controls and reconciliation in queue tabs' do
      event = create(:event, venue: venue, status: :live, starts_at: 1.hour.ago)
      theme = create(:theme, venue: venue, name: 'Disco Night')
      application = create(:event_theme_application, event: event, theme: theme)
      create(
        :performance,
        venue: venue,
        event: event,
        performer: 'Theme Singer',
        theme_admission_status: 'review',
        theme_admission_reason: 'title does not match required theme keywords',
        theme_application: application
      )
      sign_in owner

      get venue_event_queue_path(venue.slug, event_slug: event.slug)

      expect(response).to be_successful
      page = Nokogiri::HTML(response.body)
      expect(response.body).to include(
        'Queue', 'Themes', 'Temporary Hosts', 'Event', 'Theme reconciliation', 'Theme Singer'
      )
      expect(response.body).to include('1 performance needs theme review')
      expect(page.at_css('#event-panel > section.event-operations__card > h3').text).to eq('Status')
      revoke_code_form = page.at_css('form.event-operations__revoke-code')
      expect(revoke_code_form.at_css('.song-action--remove').text).to include('Revoke Code')
      delegation_form = Nokogiri::HTML(response.body).at_css('form[data-controller~="delegation-window"]')
      expect(delegation_form['data-action']).to include('submit->delegation-window#validate')
      expect(delegation_form.at_css('#event_host_delegation_starts_at')['min']).to be_present
      expect(delegation_form.at_css('#event_host_delegation_ends_at')['max']).to be_present
    end

    it 'allows an active temporary host to reconcile themes without exposing configuration controls' do
      event = create(:event, venue: venue, status: :live, starts_at: 1.hour.ago)
      delegated_host = create(:user)
      venue.venue_memberships.create!(user: delegated_host, role: :performer)
      EventHostDelegation.create!(event: event, delegated_user: delegated_host, delegated_by_user: owner,
                                  starts_at: 30.minutes.ago, ends_at: 1.hour.from_now)
      sign_in delegated_host

      get venue_event_queue_path(venue.slug, event_slug: event.slug)

      expect(response).to be_successful
      expect(response.body).to include('Host Menu', 'Presentation Mode', 'Themes', 'Theme decisions', 'Your host authority', 'This event only')
      expect(response.body).to include('No themes are scheduled for this event.', 'No songs are waiting for a theme decision.')
      expect(response.body).not_to include('Use or create a theme', 'Temporary Hosts', 'Performer access')
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

    it 'allows a venue host to enable and audit queue overrun' do
      event = create(:event, venue: venue)
      sign_in host

      patch venue_event_path(venue.slug, event), params: { event: { allow_queue_overrun: true } }

      expect(response).to redirect_to(venue_event_path(venue.slug, event))
      expect(event.reload.allow_queue_overrun?).to be(true)
      expect(event.event_setting_changes.last).to have_attributes(user: host, new_value: true)
    end

    it 'does not allow a performer to change queue overrun' do
      event = create(:event, venue: venue)
      sign_in performer

      patch venue_event_path(venue.slug, event), params: { event: { allow_queue_overrun: true } }

      expect(response).to redirect_to(venue_songs_path(venue.slug))
      expect(event.reload.allow_queue_overrun?).to be(false)
    end
  end

  describe 'event lifecycle' do
    it 'allows a permanent venue host to start a scheduled event' do
      event = create(:event, venue: venue)
      sign_in host

      patch start_venue_event_path(venue.slug, event)

      expect(response).to redirect_to(venue_event_path(venue.slug, event))
      expect(event.reload).to be_live
      expect(event.event_presence_sessions.active_at).to exist
    end

    it 'does not allow a performer to start an event' do
      event = create(:event, venue: venue)
      sign_in performer

      patch start_venue_event_path(venue.slug, event)

      expect(response).to redirect_to(venue_songs_path(venue.slug))
      expect(event.reload).to be_scheduled
    end

    it 'allows an active event host to complete a live event' do
      event = create(:event, venue: venue, status: :live)
      sign_in host

      patch complete_venue_event_path(venue.slug, event)

      expect(response).to redirect_to(venue_event_path(venue.slug, event))
      expect(event.reload).to be_completed
    end
  end

  describe 'temporary host delegation' do
    it 'lets a venue host delegate event queue authority to a venue member' do
      event = create(
        :event, venue: venue, starts_at: 1.hour.from_now.change(sec: 0), ends_at: 3.hours.from_now.change(sec: 0)
      )
      delegated_host = create(:user)
      venue.venue_memberships.create!(user: delegated_host, role: :performer)
      sign_in owner

      post venue_event_host_delegations_path(venue.slug), params: {
        event_id: event.id,
        event_host_delegation: {
          delegated_user_id: delegated_host.id,
          starts_at: event.starts_at,
          ends_at: event.ends_at
        }
      }
      expect(response).to redirect_to(venue_event_queue_path(venue.slug, event_slug: event.slug))
      expect(EventHostDelegation.last.delegated_user).to eq(delegated_host)
    end

    it 'lets a venue host delegate event queue authority to an event performer' do
      event = create(
        :event, venue: venue, starts_at: 1.hour.from_now.change(sec: 0), ends_at: 3.hours.from_now.change(sec: 0)
      )
      performer = create(:user)
      create(:performance, event: event, venue: venue, user: performer)
      sign_in owner

      post venue_event_host_delegations_path(venue.slug), params: {
        event_id: event.id,
        event_host_delegation: { delegated_user_id: performer.id, starts_at: event.starts_at, ends_at: event.ends_at }
      }

      expect(response).to redirect_to(venue_event_queue_path(venue.slug, event_slug: event.slug))
      expect(EventHostDelegation.last.delegated_user).to eq(performer)
    end

    it 'lets a venue host delegate event queue authority to a checked-in performer' do
      event = create(
        :event, venue: venue, starts_at: 1.hour.from_now.change(sec: 0), ends_at: 3.hours.from_now.change(sec: 0)
      )
      performer = create(:user)
      EventCheckIn.create!(event: event, user: performer, checked_in_at: Time.current)
      sign_in owner

      post venue_event_host_delegations_path(venue.slug), params: {
        event_id: event.id,
        event_host_delegation: { delegated_user_id: performer.id, starts_at: event.starts_at, ends_at: event.ends_at }
      }

      expect(response).to redirect_to(venue_event_queue_path(venue.slug, event_slug: event.slug))
      expect(EventHostDelegation.last.delegated_user).to eq(performer)
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
