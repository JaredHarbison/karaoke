# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Theme, type: :model do
  it { is_expected.to belong_to(:venue) }
  it { is_expected.to have_many(:event_theme_applications).dependent(:destroy) }
  it { is_expected.to have_many(:events).through(:event_theme_applications) }
  it { is_expected.to validate_presence_of(:name) }

  it 'keeps theme names unique within a venue' do
    theme = create(:theme)
    duplicate = build(:theme, venue: theme.venue, name: theme.name)

    expect(duplicate).not_to be_valid
  end
end
