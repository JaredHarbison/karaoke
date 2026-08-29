# frozen_string_literal: true

# Releases unresolved theme reviews after their theme application ends.
class ThemeAdmissionRelease
  def self.call(event:, at: Time.current)
    new(event: event, at: at).call
  end

  def initialize(event:, at:)
    @event = event
    @at = at
  end

  def call
    songs_released = 0
    Performance.unscoped.where(
      event_id: @event.id, theme_admission_status: %w[review deferred]
    ).find_each do |performance|
      songs_released += 1 if performance.release_theme!(at: @at)
    end
    songs_released
  end
end
