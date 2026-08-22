# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Event, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:venue) }
    it { is_expected.to belong_to(:event_series).optional }
    it { is_expected.to have_many(:songs).dependent(:nullify) }
    it { is_expected.to have_many(:event_host_delegations).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:starts_at) }

    it 'allows an occurrence to override the series schedule' do
      series = create(:event_series)
      event = build(:event, event_series: series, venue: series.venue,
                            starts_at: series.starts_at + 1.day, ends_at: series.ends_at + 1.day)

      expect(event).to be_valid
    end
  end

  describe 'venue validation' do
    it 'keeps an occurrence in the same venue as its series' do
      series = create(:event_series)
      event = build(:event, event_series: series, venue: create(:venue))

      expect(event).not_to be_valid
      expect(event.errors[:event_series]).to include('must belong to the same venue')
    end
  end

  describe 'lifecycle transitions' do
    it 'transitions a scheduled event to live' do
      event = create(:event)

      expect(event.start!).to be(true)
      expect(event.reload).to be_live
    end

    it 'does not complete a scheduled event' do
      event = create(:event)

      expect(event.complete!).to be(false)
      expect(event.reload).to be_scheduled
    end

    it 'does not start an event twice' do
      event = create(:event, status: :live)

      expect(event.start!).to be(false)
      expect(event.reload).to be_live
    end
  end
end
# rubocop:enable Metrics/BlockLength
