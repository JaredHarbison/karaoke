# frozen_string_literal: true

# Applies a reusable theme to one event, optionally for a time window.
class EventThemeApplication < ApplicationRecord
  belongs_to :event
  belongs_to :theme

  validates :event, :theme, presence: true
  validates :ends_at, comparison: { greater_than: :starts_at }, allow_nil: true
  validate :theme_belongs_to_event_venue

  private

  def theme_belongs_to_event_venue
    return unless event && theme && event.venue_id != theme.venue_id

    errors.add(:theme, 'must belong to the same venue as the event')
  end
end
