# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlatformMembership, type: :model do
  subject { build(:platform_membership, user: create(:user)) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_uniqueness_of(:user_id) }
  end

  describe 'roles' do
    it { is_expected.to define_enum_for(:role).with_values(admin: 0) }
  end
end
