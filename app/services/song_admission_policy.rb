# frozen_string_literal: true

# Applies provider metadata policy before an event queue entry is admitted.
class SongAdmissionPolicy
  Result = Struct.new(:status, :reason, keyword_init: true) do
    def eligible?
      status == :eligible
    end
  end

  def self.call(song:, venue:)
    new(song: song, venue: venue).call
  end

  def initialize(song:, venue:)
    @song = song
    @venue = venue
  end

  def call
    metadata = YoutubeService.validate_karaoke_video(@song.url)
    decision = YoutubeVideoPolicy.call(
      video: metadata,
      explicit_lyrics_allowed: @venue.explicit_lyrics_allowed?
    )
    record_metadata(metadata, decision)
    snapshot_duration(metadata) if decision.status == :eligible
    Result.new(status: decision.status, reason: decision.reason)
  end

  private

  def record_metadata(metadata, decision)
    @song.provider = 'youtube'
    @song.provider_video_id = metadata[:video_id]
    @song.metadata_status = decision.status
    @song.explicit_lyrics = metadata[:explicit_lyrics]
    @song.metadata_checked_at = Time.current
  end

  def snapshot_duration(metadata)
    duration = metadata[:duration_seconds]
    average = @song.known_duration_average
    @song.duration_seconds = duration
    @song.effective_duration_seconds = duration || average || Song::DEFAULT_DURATION_SECONDS
    @song.duration_source = duration_source(duration, average)
  end

  def duration_source(duration, average)
    return 'provider' if duration
    return 'average' if average

    'fallback'
  end
end
