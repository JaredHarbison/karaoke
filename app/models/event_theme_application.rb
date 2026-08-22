# frozen_string_literal: true

# Applies a reusable theme to one event, optionally for a time window.
class EventThemeApplication < ApplicationRecord
  belongs_to :event
  belongs_to :theme

  validates :event, :theme, presence: true
  validates :ends_at, comparison: { greater_than: :starts_at }, allow_nil: true
  validate :theme_belongs_to_event_venue
  validate :window_is_complete
  validate :window_is_within_event
  validate :window_does_not_overlap_event_theme

  def active_at?(time = Time.current)
    return false if starts_at && time < starts_at
    return false if ends_at && time >= ends_at

    true
  end

  private

  def theme_belongs_to_event_venue
    return unless event && theme && event.venue_id != theme.venue_id

    errors.add(:theme, 'must belong to the same venue as the event')
  end

  def window_is_complete
    return if starts_at.blank? && ends_at.blank?
    return if starts_at.present? && ends_at.present?

    errors.add(:base, 'a theme time window needs both a start and an end')
  end

  def window_is_within_event
    return unless event && bounded_window?
    return if starts_after_event_start? && ends_before_event_end?

    errors.add(:base, 'a theme time window must stay within the event')
  end

  def window_does_not_overlap_event_theme
    return unless event

    overlapping = event.event_theme_applications.where.not(id: id).any? do |application|
      windows_overlap?(application)
    end
    errors.add(:base, 'a theme time window cannot overlap another theme on the event') if overlapping
  end

  def windows_overlap?(application)
    starts_before_other_end = ends_at.nil? || application.starts_at.nil? || starts_at < application.ends_at
    other_starts_before_end = application.ends_at.nil? || starts_at.nil? || application.starts_at < ends_at
    starts_before_other_end && other_starts_before_end
  end

  def bounded_window?
    starts_at.present? && ends_at.present?
  end

  def starts_after_event_start?
    starts_at >= event.starts_at
  end

  def ends_before_event_end?
    event.ends_at.nil? || ends_at <= event.ends_at
  end
end
