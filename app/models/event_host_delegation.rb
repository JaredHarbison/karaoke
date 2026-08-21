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
  validate :users_belong_to_event_venue
  validate :delegation_is_within_event
  validate :delegated_user_is_not_delegator
  validate :delegator_is_authorized

  def active_at?(time = Time.current)
    revoked_at.nil? && starts_at <= time && ends_at > time
  end

  private

  def users_belong_to_event_venue
    return unless event

    [delegated_user, delegated_by_user].compact.each do |user|
      next if event.venue.members.exists?(user.id)

      errors.add(:base, 'delegation users must belong to the event venue')
    end
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
