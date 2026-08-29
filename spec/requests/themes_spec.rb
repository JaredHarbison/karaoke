# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Themes', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:venue) { create(:venue) }
  let(:user) { venue.owner }

  before { sign_in user }

  it 'allows a host to create a reusable theme' do
    post venue_themes_path(venue.slug), params: {
      theme: {
        name: 'Decades Night', description: 'Songs from the 1980s.',
        required_keywords_text: ' Disco, classics ', blocked_keywords_text: ' explicit '
      }
    }

    expect(response).to redirect_to(venue_themes_path(venue.slug))
    expect(Theme.last).to have_attributes(
      name: 'Decades Night', venue: venue,
      rules: { 'required_keywords' => %w[disco classics], 'blocked_keywords' => ['explicit'] }
    )
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
      event_theme_application: { event_id: event.id, theme_name: theme.name }
    }

    expect(response).to redirect_to(venue_event_queue_path(venue.slug, event_slug: event.slug))
    expect(event.reload.themes).to include(theme)
  end

  it 'creates a theme when the submitted name is new' do
    event = create(:event, venue: venue)

    expect do
      post venue_event_theme_applications_path(venue.slug), params: {
        event_theme_application: {
          event_id: event.id, theme_name: 'Late Night Disco', description: 'Four-on-the-floor favorites.',
          required_keywords_text: 'disco', blocked_keywords_text: 'ballad'
        }
      }
    end.to change(Theme, :count).by(1)

    theme = Theme.last
    expect(event.reload.themes).to include(theme)
    expect(theme).to have_attributes(
      description: 'Four-on-the-floor favorites.',
      rules: { 'required_keywords' => ['disco'], 'blocked_keywords' => ['ballad'] }
    )
  end

  it 'creates an any-match theme from familiar song and artist examples' do
    event = create(:event, venue: venue)

    post venue_event_theme_applications_path(venue.slug), params: {
      event_theme_application: {
        event_id: event.id, theme_name: 'Heartbreak', match_examples_text: 'Adele, Someone Like You'
      }
    }

    expect(Theme.last.rules).to eq('match_any_keywords' => ['adele', 'someone like you'])
  end

  it 'allows a theme to be applied in separate event windows' do
    event = create(:event, venue: venue, starts_at: 1.hour.from_now, ends_at: 4.hours.from_now)
    theme = create(:theme, venue: venue)
    create(
      :event_theme_application,
      event: event,
      theme: theme,
      starts_at: event.starts_at,
      ends_at: event.starts_at + 1.hour
    )

    expect do
      post venue_event_theme_applications_path(venue.slug), params: {
        event_theme_application: {
          event_id: event.id, theme_name: theme.name,
          starts_at: event.starts_at + 1.hour + 1.minute, ends_at: event.starts_at + 2.hours
        }
      }
    end.to change(EventThemeApplication, :count).by(1)

    expect(response).to redirect_to(venue_event_queue_path(venue.slug, event_slug: event.slug))
  end
end
# rubocop:enable Metrics/BlockLength
