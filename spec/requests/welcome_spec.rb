require 'rails_helper'

RSpec.describe 'Welcome page', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let!(:venue) { create(:venue, name: 'Franklin Karaoke', location: '523 Franklin Ave') }
  let!(:event) do
    create(:event, venue: venue, name: 'Friday Karaoke', status: :live,
                   starts_at: 1.hour.ago, ends_at: 2.hours.from_now)
  end
  let!(:private_venue) { create(:venue, :private, name: 'Hidden Karaoke') }
  let!(:empty_venue) { create(:venue, name: 'Empty Karaoke') }

  before { sign_in user }

  it 'shows public venues as discovery cards' do
    get root_path

    expect(response).to be_successful
    expect(response.body).to include('Franklin Karaoke', '523 Franklin Ave', 'open for signups')
    expect(response.body).to include('venue-card__status', 'venue-card__status-dot')
    expect(response.body).to include(venue_event_queue_path(venue.slug, event_slug: event.slug))
    expect(response.body).not_to include('Empty Karaoke')
    expect(response.body).not_to include(%(href="#{venue_songs_path(venue.slug)}"))
    expect(response.body).to include('search venues or locations')
    expect(response.body).to include('Performer Menu', venue.owner.display_name)
    expect(response.body).not_to include('PUBLIC VENUES', 'choose a venue')
    expect(response.body).not_to include('Hidden Karaoke')
  end

  it 'uses the shared event label for the resume action' do
    get venue_event_path(venue.slug, event)
    get root_path

    expect(response.body).to include('Go To Queue')
    expect(response.body).to include(venue_event_queue_path(venue.slug, event_slug: event.slug))
  end

  it 'filters public venues by search' do
    get root_path, params: { search: 'Franklin' }

    expect(response.body).to include('Franklin Karaoke')
    expect(response.body).not_to include('Hidden Karaoke')
  end

  it 'renders the sign-in page without a selected venue' do
    sign_out user

    get new_user_session_path

    expect(response).to be_successful
      expect(response.body).to include('Sign In', 'Performer Menu', 'Skip to main content')
    expect(response.body).not_to include('app-header')
  end
end
