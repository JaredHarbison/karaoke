# frozen_string_literal: true

# A one-off event or an occurrence generated from an EventSeries.
class Event < ApplicationRecord
  belongs_to :venue
  belongs_to :event_series, optional: true
  has_many :performances, dependent: :nullify
  has_many :song_queue_overrides, dependent: :destroy
  has_many :event_host_delegations, dependent: :destroy
  has_many :event_presence_sessions, dependent: :destroy
  has_many :event_setting_changes, dependent: :destroy
  has_many :event_theme_applications, dependent: :destroy
  has_many :themes, through: :event_theme_applications

  enum :status, { scheduled: 0, cancelled: 1, completed: 2, live: 3 }

  scope :current_or_upcoming, lambda {
    now = Time.current
    scheduled_events = where(status: :scheduled).where('starts_at > ?', now)
    live_events = where(status: :live).where('starts_at <= ? AND (ends_at IS NULL OR ends_at > ?)', now, now)
    scheduled_events.or(live_events)
  }

  validates :name, :starts_at, presence: true
  validates :slug, presence: true, uniqueness: { scope: :venue_id }
  validates :ends_at, comparison: { greater_than: :starts_at }, allow_nil: true
  validate :series_belongs_to_venue

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  def to_param
    slug.presence || super
  end

  def temporary_host?(user, at: Time.current)
    return false unless user

    event_host_delegations.active_at(at).where(delegated_user_id: user.id).exists?
  end

  def accepting_signups?(at: Time.current)
    live? && starts_at <= at && (ends_at.nil? || ends_at > at)
  end

  def start!
    transition_status(:scheduled, :live)
  end

  def complete!
    transition_status(:live, :completed)
  end

  def host_authorized?(user, at: Time.current)
    venue.admin?(user) || temporary_host?(user, at: at)
  end

  def record_queue_overrun_change!(user)
    return unless saved_change_to_allow_queue_overrun?

    previous_value, new_value = saved_change_to_allow_queue_overrun
    event_setting_changes.create!(
      user: user,
      setting: 'allow_queue_overrun',
      previous_value: previous_value,
      new_value: new_value
    )
  end

  private

  def series_belongs_to_venue
    return unless event_series && venue_id != event_series.venue_id

    errors.add(:event_series, 'must belong to the same venue')
  end

  def generate_slug
    base = name.parameterize.presence || "event-#{id || 'new'}"
    candidate = base
    suffix = 2

    while venue && venue.events.where.not(id: id).where(slug: candidate).exists?
      candidate = "#{base}-#{suffix}"
      suffix += 1
    end

    self.slug = candidate
  end

  def transition_status(from, to)
    with_lock do
      return false unless public_send("#{from}?")

      update!(status: to)
      true
    end
  end
end
