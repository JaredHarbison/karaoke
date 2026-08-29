# frozen_string_literal: true

# Records an authenticated performer's event-code check-in.
class EventCheckIn < ApplicationRecord
  belongs_to :event
  belongs_to :user

  before_validation :set_checked_in_at, on: :create

  validates :user_id, uniqueness: { scope: :event_id }
  validates :checked_in_at, presence: true

  private

  def set_checked_in_at
    self.checked_in_at ||= Time.current
  end
end
