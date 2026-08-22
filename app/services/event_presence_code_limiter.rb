# frozen_string_literal: true

# Applies a database-backed access-code attempt limit across web processes.
class EventPresenceCodeLimiter
  MAX_ATTEMPTS = 10
  WINDOW = 1.minute

  def self.allow?(fingerprint:, now: Time.current)
    window_started_at = window_start(now)
    attempt = find_or_create_attempt(fingerprint, window_started_at)

    attempt.with_lock do
      if attempt.attempts >= MAX_ATTEMPTS
        record_blocked_attempt!(attempt, now)
        return false
      end

      record_allowed_attempt!(attempt, now)
      true
    end
  end

  def self.window_start(time)
    Time.zone.at((time.to_i / WINDOW.to_i) * WINDOW.to_i)
  end

  def self.find_or_create_attempt(fingerprint, window_started_at)
    EventPresenceAttempt.find_or_create_by!(fingerprint: fingerprint, window_started_at: window_started_at)
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  private_class_method :find_or_create_attempt

  def self.record_blocked_attempt!(attempt, now)
    attempt.update_columns(
      blocked_attempts: attempt.blocked_attempts + 1,
      last_blocked_at: now,
      updated_at: now
    )
  end
  private_class_method :record_blocked_attempt!

  def self.record_allowed_attempt!(attempt, now)
    attempt.update_columns(
      attempts: attempt.attempts + 1,
      last_attempt_at: now,
      updated_at: now
    )
  end
  private_class_method :record_allowed_attempt!
end
