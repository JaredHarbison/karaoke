# frozen_string_literal: true

# Grants temporary host authority for one event and one user.
class EventHostDelegation < ApplicationRecord
  belongs_to :event
  belongs_to :delegated_user, class_name: 'User'
  belongs_to :delegated_by_user, class_name: 'User'

  scope :active_at, lambda { |time = Time.current|
    where(revoked_at: nil).where('starts_at <= ? AND ends_at > ?', time, time)
  }

  validates :starts_at, :ends_at, presence: true
  validates :ends_at, comparison: { greater_than: :starts_at }
  validate :delegated_user_is_eligible
  validate :delegation_is_within_event
  validate :delegated_user_is_not_delegator
  validate :delegator_is_authorized

  def active_at?(time = Time.current)
    revoked_at.nil? && starts_at <= time && ends_at > time
  end

  private

  def delegated_user_is_eligible
    return unless event && delegated_user
    return if event.eligible_for_temporary_host?(delegated_user)

    errors.add(:delegated_user, 'must be checked in, a performer at this event, or a venue member')
  end

  def delegation_is_within_event
    return unless event && starts_at && ends_at
    return if starts_at >= event.starts_at && (!event.ends_at || ends_at <= event.ends_at)

    errors.add(:base, 'delegation must fall within the event window')
  end

  def delegated_user_is_not_delegator
    return unless delegated_user_id && delegated_by_user_id && delegated_user_id == delegated_by_user_id

    errors.add(:delegated_user, 'must be different from the delegating host')
  end

  def delegator_is_authorized
    return unless event && delegated_by_user
    return if event.venue.admin?(delegated_by_user)

    errors.add(:delegated_by_user, 'must be an authorized venue host')
  end
end
