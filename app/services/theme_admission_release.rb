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
      next unless releasable?(song)

      release!(song)
      songs_released += 1
    end
    songs_released
  end

  private

  def releasable?(song)
    !song.theme_admission_reason.to_s.start_with?('content policy:') && !song.theme_application&.active_at?(@at)
  end

  def release!(song)
    song.update!(
      theme_admission_status: 'released',
      theme_admission_reason: 'theme window ended; released to normal queue'
    )
  end
end
