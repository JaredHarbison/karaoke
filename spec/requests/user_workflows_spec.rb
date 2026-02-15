require 'rails_helper'

RSpec.describe 'User Journeys', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:venue) { create(:venue) }
  let(:owner) { venue.owner }
  let(:performer) { create(:user) }
  let(:admin) { create(:user) }

  context 'Performer workflow' do
    before do
      venue.add_admin(admin)
      sign_in performer
    end

    it 'performer can view and add songs to queue', :critical do
      get "/#{venue.slug}/songs"
      expect(response).to be_successful

      post "/#{venue.slug}/songs", params: {
        song: {
          performer: 'Test Performer',
          url: 'https://youtube.com/test',
          category: 'rock'
        }
      }
      expect(Song.last.performer).to eq('Test Performer')
    end
  end

  context 'Admin workflow' do
    before do
      venue.add_admin(admin)
      sign_in admin
    end

    it 'admin can manage the queue', :critical do
      song = create(:song, venue: venue, user: performer)
      
      patch "/#{venue.slug}/songs/#{song.id}/finish_song"
      expect(song.reload.finished).to be_truthy

      song.update(finished: false)
      patch "/#{venue.slug}/songs/#{song.id}/skip_song"
      expect(song.reload.skipped).to be_truthy
    end
  end

  context 'Owner workflow' do
    before do
      sign_in owner
    end

    it 'owner can configure venue settings', :critical do
      get "/#{venue.slug}/settings"
      expect(response).to be_successful

      post "/#{venue.slug}/admins", params: { email: admin.email }
      expect(venue.reload.admins).to include(admin)
    end
  end
end
