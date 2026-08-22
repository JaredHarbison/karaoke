# frozen_string_literal: true

# Determines whether a candidate event queue entry would exceed the event end.
class EventQueueRuntimePolicy
  TRANSITION_BUFFER_SECONDS = 30

  Result = Struct.new(:status, :reason, :projected_completion_at, keyword_init: true) do
    def allowed?
      status == :allowed
    end
  end

  def self.call(event:, candidate:, at: Time.current)
    new(event: event, candidate: candidate, at: at).call
  end

  def initialize(event:, candidate:, at:)
    @event = event
    @candidate = candidate
    @at = at
  end

  def call
    projected_seconds = queue_duration_seconds + transition_buffer_seconds
    projected_completion = @at + projected_seconds

    return allowed(projected_completion) if @event.allow_queue_overrun? || no_event_end?
    return allowed(projected_completion) if projected_completion <= @event.ends_at

    rejected(projected_completion)
  end

  private

  def queue_duration_seconds
    queued_songs.sum { |song| song.effective_duration_seconds || Song::DEFAULT_DURATION_SECONDS } +
      (@candidate.effective_duration_seconds || Song::DEFAULT_DURATION_SECONDS)
  end

  def queued_songs
    scope = Song.unscoped.where(event_id: @event.id, finished: false, skipped: false, postponed: false)
    scope = scope.where.not(id: @candidate.id) if @candidate.persisted?
    scope.to_a
  end

  def transition_buffer_seconds
    (queued_songs.length + 1) * TRANSITION_BUFFER_SECONDS
  end

  def no_event_end?
    @event.ends_at.nil?
  end

  def allowed(projected_completion)
    Result.new(status: :allowed, projected_completion_at: projected_completion)
  end

  def rejected(projected_completion)
    Result.new(
      status: :rejected,
      reason: 'This song would extend the queue beyond the event end.',
      projected_completion_at: projected_completion
    )
  end
end
