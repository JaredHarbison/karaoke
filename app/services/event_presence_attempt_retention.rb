# frozen_string_literal: true

# Removes privacy-sensitive event access attempt records after their short
# operational retention window.
class EventPresenceAttemptRetention
  RETENTION = 24.hours

  def self.prune!(before: Time.current - RETENTION)
    EventPresenceAttempt.where('window_started_at < ?', before).delete_all
  end
end
