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
    Song.unscoped.where(event_id: @event.id, theme_admission_status: 'review').find_each do |song|
      next if song.theme_application&.active_at?(@at)

      song.update!(
        theme_admission_status: 'released',
        theme_admission_reason: 'theme window ended; released to normal queue'
      )
      songs_released += 1
    end
    songs_released
  end
end
