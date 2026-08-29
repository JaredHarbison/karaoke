# frozen_string_literal: true

# A revocable bearer session for presence at one event.
class EventPresenceSession < ApplicationRecord
  GRACE_PERIOD = 15.minutes
  DISPLAY_CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'

  belongs_to :event
  belongs_to :created_by_user, class_name: 'User'

  scope :active_at, ->(time = Time.current) { where(revoked_at: nil).where('expires_at > ?', time) }

  before_validation :generate_credentials, on: :create

  validates :token, presence: true, uniqueness: true
  validates :short_code, presence: true, uniqueness: true, format: { with: /\A[A-Z0-9]{6}\z/ }
  validates :expires_at, presence: true
  validate :expiry_is_within_event_window
  validate :creator_is_event_host

  def active_at?(time = Time.current)
    revoked_at.nil? && expires_at > time
  end

  def self.rotate_for!(event:, created_by_user:, expires_at:)
    event.with_lock do
      event.event_presence_sessions.active_at.update_all(revoked_at: Time.current, updated_at: Time.current)
      event.event_presence_sessions.create!(created_by_user: created_by_user, expires_at: expires_at)
    end
  end

  def self.ensure_active_for!(event:, created_by_user:, expires_at:)
    event.with_lock do
      event.event_presence_sessions.active_at.order(created_at: :desc).first ||
        event.event_presence_sessions.create!(created_by_user: created_by_user, expires_at: expires_at)
    end
  end

  private

  def generate_credentials
    self.token ||= SecureRandom.urlsafe_base64(32)
    self.short_code ||= Array.new(6) do
      DISPLAY_CODE_ALPHABET[SecureRandom.random_number(DISPLAY_CODE_ALPHABET.length)]
    end.join
  end

  def expiry_is_within_event_window
    return unless event && expires_at
    return unless event.ends_at
    return if expires_at <= event.ends_at + GRACE_PERIOD

    errors.add(:expires_at, 'must be no later than the event end')
  end

  def creator_is_event_host
    return unless event && created_by_user
    return if event.venue.admin?(created_by_user)

    errors.add(:created_by_user, 'must be an authorized venue host')
  end
end
