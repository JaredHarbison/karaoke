# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VenueMembership, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:venue) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'roles' do
    it { is_expected.to define_enum_for(:role).with_values(owner: 0, admin: 1, performer: 2) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }

    it 'prevents duplicate memberships for a venue and user', :critical do
      membership = create(:venue_membership)
      duplicate = build(:venue_membership, venue: membership.venue, user: membership.user)

      expect(duplicate).not_to be_valid
    end
  end

  it 'exposes members from both sides' do
    venue = create(:venue)
    user = create(:user)
    membership = create(:venue_membership, venue: venue, user: user)

    expect(venue.members).to include(user)
    expect(user.member_venues).to include(venue)
    expect(membership).to be_persisted
  end
end
