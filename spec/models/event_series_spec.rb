# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventSeries, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:venue) }
    it { is_expected.to have_many(:events).dependent(:nullify) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:recurrence_rule) }
    it { is_expected.to validate_presence_of(:starts_at) }

    it 'requires the end time to follow the start time' do
      series = build(
        :event_series,
        starts_at: Time.zone.parse('2026-08-21 20:00'),
        ends_at: Time.zone.parse('2026-08-21 19:00')
      )

      expect(series).not_to be_valid
      expect(series.errors[:ends_at].first).to include('must be greater than')
    end
  end
end
