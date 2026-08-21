# frozen_string_literal: true

# A revocable bearer session for presence at one event.
class EventPresenceSession < ApplicationRecord
  belongs_to :event
  belongs_to :created_by_user, class_name: 'User'

  scope :active_at, ->(time = Time.current) { where(revoked_at: nil).where('expires_at > ?', time) }

  before_validation :generate_token, on: :create

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validate :expiry_is_within_event_window
  validate :creator_is_event_host

  def active_at?(time = Time.current)
    revoked_at.nil? && expires_at > time
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def expiry_is_within_event_window
    return unless event && expires_at
    return unless event.ends_at
    return if expires_at <= event.ends_at

    errors.add(:expires_at, 'must be no later than the event end')
  end

  def creator_is_event_host
    return unless event && created_by_user
    return if event.venue.admin?(created_by_user)

    errors.add(:created_by_user, 'must be an authorized venue host')
  end
end
