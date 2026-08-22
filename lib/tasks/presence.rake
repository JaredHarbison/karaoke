# frozen_string_literal: true

namespace :presence do
  desc 'Prune expired event presence access-attempt telemetry'
  task prune_attempts: :environment do
    deleted = EventPresenceAttemptRetention.prune!
    puts "Deleted #{deleted} expired event presence attempt record(s)."
  end
end
