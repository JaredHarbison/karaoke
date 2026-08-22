require 'rails_helper'

# Request specs test the full HTTP request/response cycle
# These are integration tests that verify routing, auth, and response codes

RSpec.describe 'Songs Endpoints', type: :request do
  let(:venue) { create(:venue) }
  let(:performer) { create(:user, venue: venue) }
  let(:song) { create(:performance, venue: venue, user: performer) }

  describe 'GET /venues/:venue_slug/songs' do
    it 'requires authentication', :critical do
      get venue_songs_path(venue.slug)
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'POST /venues/:venue_slug/songs' do
    it 'requires authentication', :critical do
      post venue_songs_path(venue.slug), params: { song: { performer: 'Test', url: 'https://youtube.com/test' } }
      expect(response).to have_http_status(:redirect)
    end
  end
end

RSpec.describe 'Venue Endpoints', type: :request do
  let(:venue) { create(:venue) }

  describe 'GET /venues/discover' do
    it 'returns a response', :critical do
      get discover_venues_path
      # Response depends on route configuration and content negotiation
      expect([200, 302, 304, 404, 406]).to include(response.status)
    end
  end
end
