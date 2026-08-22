# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Song, type: :model do
  describe 'canonical provider identity' do
    it 'stores provider metadata independently from event performances' do
      song = create(:canonical_song, provider_video_id: 'canonical-video')
      performance = create(:performance, song: song)

      expect(song.performances).to contain_exactly(performance)
      expect(song).to have_attributes(
        provider: 'youtube', provider_video_id: 'canonical-video', verified_karaoke: true
      )
    end

    it 'requires a provider video identity' do
      song = build(:canonical_song, provider_video_id: nil)

      expect(song).not_to be_valid
      expect(song.errors[:provider_video_id]).to include("can't be blank")
    end

    it 'does not duplicate a provider video identity' do
      create(:canonical_song, provider: 'youtube', provider_video_id: 'duplicate-video')
      duplicate = build(:canonical_song, provider: 'youtube', provider_video_id: 'duplicate-video')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:provider_video_id]).to include('has already been taken')
    end
  end
end
