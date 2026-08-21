# frozen_string_literal: true

# A one-off event or an occurrence generated from an EventSeries.
class Event < ApplicationRecord
  belongs_to :venue
  belongs_to :event_series, optional: true
  has_many :songs, dependent: :nullify
  has_many :song_queue_overrides, dependent: :destroy
  has_many :event_host_delegations, dependent: :destroy
  has_many :event_presence_sessions, dependent: :destroy
  has_many :event_theme_applications, dependent: :destroy
  has_many :themes, through: :event_theme_applications

  enum :status, { scheduled: 0, cancelled: 1, completed: 2 }

  validates :name, :starts_at, presence: true
  validates :ends_at, comparison: { greater_than: :starts_at }, allow_nil: true
  validate :series_belongs_to_venue

  def temporary_host?(user, at: Time.current)
    return false unless user

    event_host_delegations.active_at(at).where(delegated_user_id: user.id).exists?
  end

  def host_authorized?(user, at: Time.current)
    venue.admin?(user) || temporary_host?(user, at: at)
  end

  private

  def series_belongs_to_venue
    return unless event_series && venue_id != event_series.venue_id

    errors.add(:event_series, 'must belong to the same venue')
  end
end
