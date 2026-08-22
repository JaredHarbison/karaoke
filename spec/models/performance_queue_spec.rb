require 'rails_helper'

RSpec.describe Performance, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:venue).optional }
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:event).optional }
    it { is_expected.to belong_to(:theme_application).class_name('EventThemeApplication').optional }
    it { is_expected.to belong_to(:theme_reviewed_by).class_name('User').optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:performer) }
  end

  describe 'scopes' do
    describe '.queued' do
      it 'returns only queued songs', :critical do
        create(:performance, :queued)
        create(:performance, :finished)
        create(:performance, :skipped)
        expect(Performance.queued.count).to eq(1)
      end
    end

    describe '.finished' do
      it 'returns only finished songs' do
        create(:performance, :finished)
        create(:performance, :queued)
        create(:performance, :skipped)
        expect(Performance.finished.count).to eq(1)
      end
    end

    describe '.skipped' do
      it 'returns only skipped songs' do
        create(:performance, :skipped)
        create(:performance, :queued)
        create(:performance, :finished)
        expect(Performance.skipped.count).to eq(1)
      end
    end

    describe '.postponed' do
      it 'returns only postponed songs' do
        create(:performance, :postponed)
        create(:performance, :queued)
        create(:performance, :finished)
        expect(Performance.postponed.count).to eq(1)
      end
    end
  end

  describe 'song states' do
    it 'starts as queued' do
      song = build(:performance)
      expect(song.finished).to be false
      expect(song.skipped).to be false
      expect(song.postponed).to be false
    end

    it 'can be marked as finished' do
      song = create(:performance)
      song.update(finished: true)
      expect(song.reload.finished).to be true
    end

    it 'can be marked as skipped' do
      song = create(:performance)
      song.update(skipped: true)
      expect(song.reload.skipped).to be true
    end

    it 'can be marked as postponed', :critical do
      song = create(:performance)
      song.update(postponed: true)
      expect(song.reload.postponed).to be true
    end
  end

  describe 'submission idempotency' do
    it 'generates a submission token for new songs' do
      expect(build(:performance).submission_token).to be_present
    end

    it 'requires submission tokens to be unique when present' do
      song = create(:performance)
      duplicate = build(:performance, submission_token: song.submission_token)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:submission_token]).to include('has already been taken')
    end
  end

  describe 'venue isolation' do
    it 'does not allow an event from another venue' do
      venue = create(:venue)
      other_event = create(:event)

      song = build(:performance, venue: venue, event: other_event)

      expect(song).not_to be_valid
      expect(song.errors[:event]).to include('must belong to the same venue')
    end

    it 'belongs to a specific venue' do
      venue1 = create(:venue)
      create(:venue)
      song = create(:performance, venue: venue1)
      expect(song.venue_id).to eq(venue1.id)
      expect(song.venue).to eq(venue1)
    end

    it 'different venues have separate songs', :critical do
      venue1 = create(:venue, :with_songs, song_count: 3)
      venue2 = create(:venue, :with_songs, song_count: 2)
      expect(venue1.performances.count).to eq(3)
      expect(venue2.performances.count).to eq(2)
    end
  end

  describe 'user association' do
    it 'belongs to a user who added it' do
      user = create(:user)
      song = create(:performance, user: user)
      expect(song.user).to eq(user)
    end

    it 'preserves user association when song is modified' do
      user = create(:user)
      song = create(:performance, user: user)
      song.update(finished: true)
      expect(song.reload.user).to eq(user)
    end
  end

  describe 'factory' do
    it 'creates a valid song' do
      song = build(:performance)
      expect(song).to be_valid
    end

    it 'creates with YouTube URL' do
      song = create(:performance)
      expect(song.url).to include('youtube.com')
    end

    context 'queued trait' do
      it 'creates a song that is queued' do
        song = build(:performance, :queued)
        expect(song.finished).to be false
        expect(song.skipped).to be false
        expect(song.postponed).to be false
      end
    end

    context 'finished trait' do
      it 'creates a finished song' do
        song = build(:performance, :finished)
        expect(song.finished).to be true
      end
    end

    context 'skipped trait' do
      it 'creates a skipped song' do
        song = build(:performance, :skipped)
        expect(song.skipped).to be true
      end
    end

    context 'postponed trait' do
      it 'creates a postponed song' do
        song = build(:performance, :postponed)
        expect(song.postponed).to be true
      end
    end
  end
end
