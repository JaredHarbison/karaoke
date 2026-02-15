require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:venue).optional }
    it { is_expected.to have_many(:owned_venues).class_name('Venue').with_foreign_key(:owner_id).dependent(:nullify) }
    it { is_expected.to have_many(:admin_for_venues).class_name('VenueAdmin').dependent(:destroy) }
    it { is_expected.to have_many(:venues_as_admin).through(:admin_for_venues).source(:venue) }
    it { is_expected.to have_many(:songs).dependent(:nullify) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:role).with_values(owner: 0, admin: 1, performer: 2) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    # Password validation is handled by Devise
  end

  describe '#owner_of?' do
    context 'when user owns the venue' do
      it 'returns true', :critical do
        user = create(:user, :owner)
        venue = create(:venue, owner: user)
        expect(user.owner_of?(venue)).to be true
      end
    end

    context 'when user does not own the venue' do
      it 'returns false', :critical do
        user = create(:user)
        venue = create(:venue)
        expect(user.owner_of?(venue)).to be false
      end
    end
  end

  describe '#admin_of?' do
    context 'when user owns the venue' do
      it 'returns true (owner is implicitly admin)', :critical do
        owner = create(:user, :owner)
        venue = create(:venue, owner: owner)
        expect(owner.admin_of?(venue)).to be true
      end
    end

    context 'when user is explicit admin' do
      it 'returns true' do
        owner = create(:user, :owner)
        venue = create(:venue, owner: owner)
        user = create(:user, :admin)
        venue.add_admin(user)
        expect(user.admin_of?(venue)).to be true
      end
    end

    context 'when user is not admin' do
      it 'returns false', :critical do
        user = create(:user, :performer)
        venue = create(:venue)
        expect(user.admin_of?(venue)).to be false
      end
    end
  end

  describe 'devise modules' do
    it 'responds to password=' do
      user = build(:user)
      expect(user).to respond_to(:password=)
    end

    it 'encrypts password after create' do
      user = create(:user)
      # Devise encrypts the password by default
      expect(user.encrypted_password).to be_present
      expect(user.encrypted_password.length).to be > 20
    end
  end

  describe 'factory' do
    it 'creates a valid user' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'creates unique emails' do
      user1 = create(:user)
      user2 = build(:user)
      expect(user2.email).not_to eq(user1.email)
    end

    context 'with owner trait' do
      it 'creates a user with owner role' do
        user = build(:user, :owner)
        expect(user.role).to eq('owner')
      end
    end

    context 'with admin trait' do
      it 'creates a user with admin role' do
        user = build(:user, :admin)
        expect(user.role).to eq('admin')
      end
    end

    context 'with performer trait' do
      it 'creates a user with performer role', :critical do
        user = build(:user, :performer)
        expect(user.role).to eq('performer')
      end
    end

    context 'with_venue trait' do
      it 'associates the user with a venue' do
        user = create(:user, :with_venue)
        expect(user.venue).not_to be_nil
      end
    end

    context 'with_oauth trait' do
      it 'sets provider and uid' do
        user = build(:user, :with_oauth)
        expect(user.provider).to eq('google_oauth2')
        expect(user.uid).not_to be_nil
      end
    end
  end

  describe 'role transitions' do
    it 'can change from performer to admin' do
      user = create(:user, :performer)
      user.update(role: :admin)
      expect(user.reload.role).to eq('admin')
    end

    it 'can change from admin to performer' do
      user = create(:user, :admin)
      user.update(role: :performer)
      expect(user.reload.role).to eq('performer')
    end
  end
end
