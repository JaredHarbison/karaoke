require 'rails_helper'

RSpec.describe 'Songs', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:venue) { create(:venue) }
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /venues/:venue_slug/songs' do
    it 'displays songs for the venue', :critical do
      create(:song, venue: venue, user: user)
      get "/#{venue.slug}/songs"
      expect(response).to be_successful
    end

    it 'requires authentication' do
      sign_out user
      get "/#{venue.slug}/songs"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'POST /venues/:venue_slug/songs' do
    it 'creates a new song', :critical do
      expect {
        post "/#{venue.slug}/songs", params: { song: { performer: 'Test Artist', url: 'https://youtube.com/test', category: 'pop' } }
      }.to change(Song, :count).by(1)
      expect(response).to redirect_to("/#{venue.slug}/songs")
    end
  end

  describe 'DELETE /venues/:venue_slug/songs/:id' do
    let(:song) { create(:song, venue: venue, user: user) }

    it 'deletes the song', :critical do
      expect {
        delete "/#{venue.slug}/songs/#{song.id}"
      }.to change(Song, :count).by(-1)
      expect(response).to redirect_to("/#{venue.slug}/songs")
    end
  end

  describe 'PATCH /venues/:venue_slug/songs/:id/finish_song' do
    let(:song) { create(:song, venue: venue, user: user) }

    it 'marks song as finished', :critical do
      patch "/#{venue.slug}/songs/#{song.id}/finish_song"
      expect(song.reload.finished).to be_truthy
    end
  end

  describe 'PATCH /venues/:venue_slug/songs/:id/skip_song' do
    let(:song) { create(:song, venue: venue, user: user) }

    it 'marks song as skipped', :critical do
      patch "/#{venue.slug}/songs/#{song.id}/skip_song"
      expect(song.reload.skipped).to be_truthy
    end
  end

  describe 'PATCH /venues/:venue_slug/songs/:id' do
    let(:song) { create(:song, venue: venue, user: user) }

    it 'updates the song', :critical do
      patch "/#{venue.slug}/songs/#{song.id}", params: { song: { performer: 'Updated Artist' } }
      expect(song.reload.performer).to eq('Updated Artist')
    end
  end

  describe 'GET /venues/:venue_slug/songs/:id' do
    let(:song) { create(:song, venue: venue, user: user) }

    it 'displays the song', :critical do
      get "/#{venue.slug}/songs/#{song.id}"
      expect(response).to be_successful
    end
  end
end
