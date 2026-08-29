# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Event theme applications', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:venue) { create(:venue) }

  before { sign_in venue.owner }

  it 'persists an optional event-time window' do
    event = create(:event, venue: venue)
    theme = create(:theme, venue: venue)
    post venue_event_theme_applications_path(venue.slug), params: application_params(event, theme)

    expect(EventThemeApplication.last).to have_attributes(theme: theme, event: event)
  end

  private

  def application_params(event, theme)
    {
      event_theme_application: {
        event_id: event.id,
        theme_name: theme.name,
        starts_at: event.starts_at + 1.hour,
        ends_at: event.ends_at - 1.hour
      }
    }
  end
end
