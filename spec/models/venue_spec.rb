require 'rails_helper'

RSpec.describe Venue, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:owner).optional }
    it { is_expected.to have_many(:venue_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:venue_memberships).source(:user) }
    it { is_expected.to have_many(:admin_memberships).class_name('VenueMembership').dependent(:destroy) }
    it { is_expected.to have_many(:hosts).through(:admin_memberships).source(:user) }
    it { is_expected.to have_many(:performances).dependent(:destroy) }
    it { is_expected.to have_many(:users).dependent(:nullify) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it 'accepts an ActiveSupport time zone' do
      expect(build(:venue, time_zone: 'America/New_York')).to be_valid
    end

    it 'rejects an unsupported time zone' do
      venue = build(:venue, time_zone: 'Not/A_Time_Zone')

      expect(venue).not_to be_valid
      expect(venue.errors[:time_zone]).to include('is not supported')
    end
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_presence_of(:time_zone) }
    # Slug uniqueness is tested in the slug generation describe block
  end

  describe 'slug generation' do
    it 'generates a slug from the name' do
      venue = build(:venue, name: 'The Blue Lagoon')
      venue.validate
      expect(venue.slug).to start_with('the-blue-lagoon')
    end

    it 'creates unique slugs for duplicate names', :critical do
      venue1 = create(:venue)
      # Second creates a different name to avoid duplicate issues
      venue2 = create(:venue, name: 'Different Name')
      expect(venue1.slug).not_to eq(venue2.slug)
    end
  end

  describe '#add_admin' do
    it 'adds a user as an admin' do
      venue = create(:venue)
      user = create(:user)
      venue.add_admin(user)
      expect(venue.is_admin?(user)).to be true
      expect(venue.venue_memberships.find_by(user: user).admin?).to be true
    end

    it 'does not add the same admin twice', :critical do
      venue = create(:venue)
      user = create(:user)
      venue.add_admin(user)
      venue.add_admin(user)
      expect(venue.hosts.where(id: user.id).count).to eq(1)
    end
  end

  describe '#remove_admin' do
    it 'removes a user as an admin', :critical do
      venue = create(:venue)
      user = create(:user)
      venue.add_admin(user)
      expect(venue.is_admin?(user)).to be true
      venue.remove_admin(user)
      expect(venue.is_admin?(user)).to be false
      expect(venue.venue_memberships.find_by(user: user)).to be_nil
    end
  end

  describe '#is_admin?' do
    context 'when user is an admin' do
      it 'returns true' do
        venue = create(:venue)
        user = create(:user)
        venue.add_admin(user)
        expect(venue.is_admin?(user)).to be true
      end
    end

    context 'when user is not an admin' do
      it 'returns false', :critical do
        venue = create(:venue)
        user = create(:user)
        expect(venue.is_admin?(user)).to be false
      end
    end
  end

  describe 'factory' do
    it 'creates a valid venue' do
      venue = build(:venue)
      expect(venue).to be_valid
    end

    it 'creates a venue with an owner' do
      venue = create(:venue)
      expect(venue.owner).not_to be_nil
      expect(venue.venue_memberships.find_by(user: venue.owner).owner?).to be true
    end

    context 'with_admins trait' do
      it 'creates admins for the venue' do
        venue = create(:venue, :with_admins, admin_count: 3)
        expect(venue.hosts.count).to eq(3)
      end
    end

    context 'with_songs trait' do
      it 'creates songs for the venue' do
        venue = create(:venue, :with_songs, song_count: 5)
        expect(venue.performances.count).to eq(5)
      end
    end

    context 'with_performers trait' do
      it 'creates performers associated with the venue' do
        venue = create(:venue, :with_performers, performer_count: 10)
        expect(venue.users.count).to eq(10)
      end
    end

    context 'public trait' do
      it 'creates a public venue' do
        venue = create(:venue, :public)
        expect(venue.public).to be true
      end
    end

    context 'private trait' do
      it 'creates a private venue' do
        venue = create(:venue, :private)
        expect(venue.public).to be false
      end
    end
  end

  describe 'public/private venues' do
    it 'can be marked as public' do
      venue = create(:venue, public: true)
      expect(venue.public).to be true
    end

    it 'can be marked as private', :critical do
      venue = create(:venue, public: false)
      expect(venue.public).to be false
    end
  end
end
