# frozen_string_literal: true

# Materializes deterministic Event records from supported series recurrence rules.
class EventSeriesOccurrenceGenerator
  DAY_NAMES = %w[SU MO TU WE TH FR SA].freeze

  def initialize(event_series, through:)
    @event_series = event_series
    @through = through.in_time_zone(event_series.time_zone)
  end

  def call
    validate_frequency!
    occurrences = []

    local_date_range.each do |date|
      next unless occurrence_date?(date)

      occurrences << upsert_occurrence(date)
    end

    occurrences
  end

  private

  attr_reader :event_series, :through

  def recurrence_parts
    @recurrence_parts ||= event_series.recurrence_rule.split(';').to_h do |part|
      key, value = part.split('=', 2)
      [key, value]
    end
  end

  def validate_frequency!
    return if %w[DAILY WEEKLY].include?(recurrence_parts['FREQ'])

    raise ArgumentError, 'Only DAILY and WEEKLY recurrence rules are supported'
  end

  def local_date_range
    first_date = event_series.starts_at.in_time_zone(event_series.time_zone).to_date
    last_date = through.to_date
    return [] if last_date < first_date

    first_date..last_date
  end

  def occurrence_date?(date)
    return true if recurrence_parts['FREQ'] == 'DAILY'

    weekdays = recurrence_parts['BYDAY'].to_s.split(',')
    weekdays.include?(DAY_NAMES[date.wday])
  end

  def occurrence_start(date)
    local_start = event_series.starts_at.in_time_zone(event_series.time_zone)
    ActiveSupport::TimeZone[event_series.time_zone].local(
      date.year, date.month, date.day, local_start.hour, local_start.min, local_start.sec
    )
  end

  def upsert_occurrence(date)
    starts_at = occurrence_start(date)
    event = event_series.events.find_or_initialize_by(starts_at: starts_at)
    return event if event.persisted?

    create_occurrence(event, starts_at)
  end

  def create_occurrence(event, starts_at)
    event.assign_attributes(
      venue: event_series.venue,
      name: event_series.name,
      ends_at: series_duration && starts_at + series_duration,
      status: :scheduled
    )
    event.save!
    event
  end

  def series_duration
    return unless event_series.ends_at

    event_series.ends_at - event_series.starts_at
  end
end
