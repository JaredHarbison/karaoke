# frozen_string_literal: true

# Applies provider metadata policy before an event queue entry is admitted.
class SongAdmissionPolicy
  Result = Struct.new(:status, :reason, keyword_init: true) do
    def eligible?
      status == :eligible
    end

    def saveable?
      eligible? || status == :review && reason.start_with?('content policy:')
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
    payload = { event_id: @song.event_id, venue_id: @venue.id }

    ActiveSupport::Notifications.instrument('song_admission_policy.karaoke', payload) do
      result = admit
      payload[:status] = result.status
      result
    end
  end

  private

  def admit
    metadata = provider_metadata
    decision = YoutubeVideoPolicy.call(
      video: metadata,
      explicit_lyrics_allowed: @venue.explicit_lyrics_allowed?
    )
    @song.song = SongCatalog.record!(metadata)
    record_metadata(metadata, decision)
    admit_eligible_song(metadata) if decision.status == :eligible
    return content_policy_review(metadata, decision) if decision.status == :rejected

    Result.new(status: decision.status, reason: decision.reason)
  end

  def provider_metadata
    SongCatalog.metadata_for(@song.url) || YoutubeService.validate_karaoke_video(@song.url)
  end

  def record_metadata(metadata, decision)
    @song.provider = 'youtube'
    @song.provider_video_id = metadata[:video_id]
    @song.metadata_status = decision.status
    @song.title = metadata[:title] if metadata[:title].present?
    @song.explicit_lyrics = metadata[:explicit_lyrics]
    @song.metadata_checked_at = Time.current
  end

  def admit_eligible_song(metadata)
    snapshot_duration(metadata)
    record_theme_admission(metadata)
  end

  def content_policy_review(metadata, decision)
    theme_decision = ThemeAdmissionPolicy.call(event: @song.event, metadata: metadata) if @song.event
    return Result.new(status: decision.status, reason: decision.reason) unless theme_decision&.application

    @song.assign_theme_admission(
      application: theme_decision.application,
      status: 'review',
      reason: "content policy: #{decision.reason}"
    )
    Result.new(status: :review, reason: @song.theme_admission_reason)
  end

  def snapshot_duration(metadata)
    duration = metadata[:duration_seconds]
    average = @song.known_duration_average
    @song.duration_seconds = duration
    @song.effective_duration_seconds = duration || average || Performance::DEFAULT_DURATION_SECONDS
    @song.duration_source = duration_source(duration, average)
  end

  def duration_source(duration, average)
    return 'provider' if duration
    return 'average' if average

    'fallback'
  end

  def record_theme_admission(metadata)
    return record_no_event_theme_admission unless @song.event

    decision = ThemeAdmissionPolicy.call(event: @song.event, metadata: metadata)
    @song.assign_theme_admission(
      application: decision.application,
      status: decision.status,
      reason: decision.reason
    )
  end

  def record_no_event_theme_admission
    @song.assign_theme_admission(application: nil, status: 'not_applicable', reason: 'no event')
  end
end
