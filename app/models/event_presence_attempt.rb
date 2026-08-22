# frozen_string_literal: true

# Stores a short-lived, privacy-preserving access-code attempt counter.
class EventPresenceAttempt < ApplicationRecord
  validates :fingerprint, :window_started_at, presence: true
  validates :attempts, numericality: { greater_than_or_equal_to: 0 }
end
