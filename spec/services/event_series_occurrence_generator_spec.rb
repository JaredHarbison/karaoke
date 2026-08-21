# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe EventSeriesOccurrenceGenerator, type: :service do
  describe '#call' do
    it 'generates weekly occurrences on the requested weekdays' do
      series = create(
        :event_series,
        recurrence_rule: 'FREQ=WEEKLY;BYDAY=FR',
        starts_at: Time.zone.parse('2026-08-21 20:00'),
        ends_at: Time.zone.parse('2026-08-21 23:00')
      )

      occurrences = described_class.new(series, through: Time.zone.parse('2026-09-11 23:59')).call

      expect(occurrences.map(&:starts_at).map(&:to_date)).to eq(
        [Date.new(2026, 8, 21), Date.new(2026, 8, 28), Date.new(2026, 9, 4), Date.new(2026, 9, 11)]
      )
      expect(occurrences.first.ends_at - occurrences.first.starts_at).to eq(3.hours)
    end

    it 'is idempotent when called more than once' do
      series = create(:event_series, recurrence_rule: 'FREQ=DAILY')
      generator = described_class.new(series, through: series.starts_at + 2.days)

      expect { generator.call }.to change(Event, :count).by(3)
      expect { generator.call }.not_to change(Event, :count)
    end

    it 'rejects unsupported recurrence frequencies' do
      series = create(:event_series, recurrence_rule: 'FREQ=MONTHLY')

      expect { described_class.new(series, through: 1.month.from_now).call }
        .to raise_error(ArgumentError, /Only DAILY and WEEKLY/)
    end
  end
end
# rubocop:enable Metrics/BlockLength
