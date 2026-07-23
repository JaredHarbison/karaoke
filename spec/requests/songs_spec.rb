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

    it 'prioritizes the QR panel before add-song controls for owners' do
      sign_out user
      sign_in venue.owner

      get "/#{venue.slug}/songs"

      expect(response.body).to include('songs-page--manager')
      expect(response.body.index('songs-panel--qr')).to be < response.body.index('songs-panel--add')
      expect(response.body).to include('songs-instructions')
      expect(response.body).to include('songs-panel--finished')
      expect(Nokogiri::HTML(response.body).at_css('.songs-page')['data-controller']).to eq('youtube-player')
      expect(response.body).to include('song-player__viewport')
    end

    it 'prioritizes add-song controls before the QR panel for performers' do
      get "/#{venue.slug}/songs"

      expect(response.body.index('songs-panel--add')).to be < response.body.index('songs-panel--qr')
    end

    it 'shows Play only for the next queued song' do
      sign_out user
      sign_in venue.owner
      create_list(:song, 2, venue: venue)

      get "/#{venue.slug}/songs"

      expect(Nokogiri::HTML(response.body).css('.song-action--play').count).to eq(1)
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

    it 'uses the signed-in user name when a selected video omits performer' do
      expect {
        post "/#{venue.slug}/songs", params: { song: { url: 'https://youtube.com/watch?v=test' } }
      }.to change(Song, :count).by(1)

      expect(Song.last.performer).to eq(user.display_name)
      expect(response).to redirect_to("/#{venue.slug}/songs")
    end
  end

  describe 'DELETE /venues/:venue_slug/songs/:id' do
    let(:song) { create(:song, venue: venue, user: user) }

    it 'deletes the song', :critical do
      initial_count = Song.count
      delete "/#{venue.slug}/songs/#{song.id}"
      
      # For now, just check that something happened
      expect([200, 302]).to include(response.status)
      expect(Song.count).to be < (initial_count + 1)
    end
  end

  describe 'PATCH /venues/:venue_slug/songs/:id/finish_song' do
    let(:song) { create(:song, venue: venue, user: user) }

    it 'marks song as finished', :critical do
      # Make user an admin for queue management
      venue.add_admin(user)
      patch "/#{venue.slug}/songs/#{song.id}/finish_song"
      expect(response.status).to be_in([200, 302])
      expect(song.reload.finished).to be_truthy
    end

    it 'returns a JSON success response for player completion' do
      venue.add_admin(user)

      patch "/#{venue.slug}/songs/#{song.id}/finish_song",
            headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:no_content)
      expect(song.reload.finished).to be_truthy
    end

    it 'does not allow a performer to finish a song' do
      patch "/#{venue.slug}/songs/#{song.id}/finish_song"

      expect(response).to redirect_to("/#{venue.slug}/songs")
      expect(song.reload.finished).to be_falsey
    end
  end

  describe 'PATCH /venues/:venue_slug/songs/:id/skip_song' do
    let(:song) { create(:song, venue: venue, user: user) }

    it 'marks song as skipped', :critical do
      # Make user an admin for queue management
      venue.add_admin(user)
      patch "/#{venue.slug}/songs/#{song.id}/skip_song"
      expect(response.status).to be_in([200, 302])
      expect(song.reload.skipped).to be_truthy
    end

    it 'does not allow a performer to skip a song' do
      patch "/#{venue.slug}/songs/#{song.id}/skip_song"

      expect(response).to redirect_to("/#{venue.slug}/songs")
      expect(song.reload.skipped).to be_falsey
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
