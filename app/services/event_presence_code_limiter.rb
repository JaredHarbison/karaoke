# frozen_string_literal: true

# Applies a database-backed access-code attempt limit across web processes.
class EventPresenceCodeLimiter
  MAX_ATTEMPTS = 10
  WINDOW = 1.minute

  def self.allow?(fingerprint:, now: Time.current)
    window_started_at = window_start(now)
    attempt = find_or_create_attempt(fingerprint, window_started_at)

    attempt.with_lock do
      return false if attempt.attempts >= MAX_ATTEMPTS

      attempt.increment!(:attempts)
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
end
