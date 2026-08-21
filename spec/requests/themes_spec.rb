# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Themes', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:venue) { create(:venue) }
  let(:user) { venue.owner }

  before { sign_in user }

  it 'allows a host to create a reusable theme' do
    post venue_themes_path(venue.slug), params: {
      theme: { name: 'Decades Night', description: 'Songs from the 1980s.' }
    }

    expect(response).to redirect_to(venue_themes_path(venue.slug))
    expect(Theme.last).to have_attributes(name: 'Decades Night', venue: venue)
  end

  it 'denies theme management to performers' do
    sign_in create(:user)

    get venue_themes_path(venue.slug)

    expect(response).to redirect_to(venue_songs_path(venue.slug))
  end

  it 'allows a host to apply a theme to an event' do
    event = create(:event, venue: venue)
    theme = create(:theme, venue: venue)

    post venue_event_theme_applications_path(venue.slug), params: {
      event_theme_application: { event_id: event.id, theme_id: theme.id }
    }

    expect(response).to redirect_to(venue_event_path(venue.slug, event))
    expect(event.reload.themes).to include(theme)
  end
end
