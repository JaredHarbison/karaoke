# frozen_string_literal: true

# Adds privacy-preserving operational telemetry for event access attempts.
class AddTelemetryToEventPresenceAttempts < ActiveRecord::Migration[7.2]
  def change
    add_column :event_presence_attempts, :last_attempt_at, :datetime
    add_column :event_presence_attempts, :blocked_attempts, :integer, null: false, default: 0
    add_column :event_presence_attempts, :last_blocked_at, :datetime
  end
end
