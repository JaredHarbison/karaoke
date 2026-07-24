require 'rails_helper'

RSpec.describe 'Venues', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:venue) { create(:venue) }
  let(:owner) { venue.owner }
  let(:admin) { create(:user) }

  describe 'GET /discover' do
    it 'displays venues for discovery', :critical do
      venue
      get '/discover'
      expect(response).to be_successful
    end
  end

  describe 'POST /venues/join/:slug' do
    it 'returns a response when joining a public venue', :critical do
      post "/venues/join/#{venue.slug}"
      expect(response.status).to be_in([200, 302, 404])
    end
  end

  describe 'GET /:venue_slug/settings' do
    it 'displays venue settings for owner', :critical do
      sign_in owner
      get "/#{venue.slug}/settings"
      expect(response).to be_successful
      expect(response.body).to include('Venue Details', 'Your Hosts', 'Add a Host')
    end

    it 'redirects if not owner or admin' do
      user = create(:user)
      sign_in user
      get "/#{venue.slug}/settings"
      expect(response).to redirect_to("/#{venue.slug}/songs")
    end

    it 'does not allow a host to access settings' do
      venue.add_host(admin)
      sign_in admin

      get "/#{venue.slug}/settings"

      expect(response).to redirect_to("/#{venue.slug}/songs")
    end
  end

  describe 'PATCH /:venue_slug/settings' do
    it 'updates venue settings for owner', :critical do
      sign_in owner
      patch "/#{venue.slug}/settings", params: { venue: { name: 'Updated Venue' } }
      expect(response).to redirect_to(venue_settings_path(venue.slug))
      expect(venue.reload.name).to eq('Updated Venue')
    end
  end

  describe 'POST /:venue_slug/admins' do
    it 'adds admin to venue for owner', :critical do
      sign_in owner
      post "/#{venue.slug}/admins", params: { email: admin.email }
      expect(response.status).to be_in([200, 302])
    end

    it 'redirects Turbo host additions back to settings with a notice' do
      sign_in owner
      post "/#{venue.slug}/admins", params: { email: admin.email }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(venue_settings_path(venue.slug))
      expect(response.headers['location']).to end_with("/#{venue.slug}/settings")
    end

    it 'does not add the owner as a host' do
      sign_in owner
      post "/#{venue.slug}/admins", params: { email: owner.email }

      expect(venue.reload.admins).not_to include(owner)
      expect(response).to redirect_to(venue_settings_path(venue.slug))
    end
  end

  describe 'DELETE /:venue_slug/admins/:id' do
    before do
      venue.add_admin(admin)
    end

    it 'removes admin from venue for owner', :critical do
      sign_in owner
      delete "/#{venue.slug}/admins/#{admin.id}"
      expect(response.status).to be_in([200, 302])
    end
  end
end
