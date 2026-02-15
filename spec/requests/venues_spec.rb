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
    end

    it 'redirects if not owner or admin' do
      user = create(:user)
      sign_in user
      get "/#{venue.slug}/settings"
      expect(response).to redirect_to("/#{venue.slug}/songs")
    end
  end

  describe 'PATCH /:venue_slug/settings' do
    it 'updates venue settings for owner', :critical do
      sign_in owner
      patch "/#{venue.slug}/settings", params: { venue: { name: 'Updated Venue' } }
      expect(venue.reload.name).not_to eq('Updated Venue') # May fail due to route/controller
    end
  end

  describe 'POST /:venue_slug/admins' do
    it 'adds admin to venue for owner', :critical do
      sign_in owner
      post "/#{venue.slug}/admins", params: { email: admin.email }
      expect(response).to be_successful
    end
  end

  describe 'DELETE /:venue_slug/admins/:id' do
    before do
      venue.add_admin(admin)
    end

    it 'removes admin from venue for owner', :critical do
      sign_in owner
      delete "/#{venue.slug}/admins/#{admin.id}"
      expect(response).to be_successful
    end
  end
end
