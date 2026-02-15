require 'rails_helper'

RSpec.describe VenueAdmin, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:venue) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:venue_id) }
    it { is_expected.to validate_presence_of(:user_id) }
  end

  describe 'uniqueness constraint' do
    it 'prevents duplicate venue-admin combinations', :critical do
      venue = create(:venue)
      user = create(:user)
      create(:venue_admin, venue: venue, user: user)
      
      duplicate = build(:venue_admin, venue: venue, user: user)
      expect(duplicate).not_to be_valid
    end
  end

  describe 'creating venue admins' do
    it 'successfully creates a venue admin', :critical do
      venue = create(:venue)
      user = create(:user, :admin)
      venue_admin = create(:venue_admin, venue: venue, user: user)
      
      expect(venue_admin).to be_persisted
      expect(venue.admins.include?(user)).to be true
    end
  end

  describe 'removing venue admins' do
    it 'deletes the venue admin association', :critical do
      venue = create(:venue)
      user = create(:user, :admin)
      venue_admin = create(:venue_admin, venue: venue, user: user)
      
      expect(venue.admins.count).to eq(1)
      venue_admin.destroy
      expect(venue.reload.admins.count).to eq(0)
    end
  end

  describe 'factory' do
    it 'creates a valid venue admin' do
      owner = create(:user, :owner)
      venue = create(:venue, owner: owner)
      user = create(:user, :admin)
      venue_admin = build(:venue_admin, venue: venue, user: user)
      expect(venue_admin).to be_valid
    end

    context 'with_owner_and_admin trait' do
      it 'creates venue admin with associated models' do
        venue_admin = create(:venue_admin, :with_owner_and_admin)
        expect(venue_admin.venue).not_to be_nil
        expect(venue_admin.user).not_to be_nil
      end
    end
  end
end
