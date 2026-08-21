# frozen_string_literal: true

# Decides whether provider metadata is sufficient for future queue admission.
class YoutubeVideoPolicy
  Result = Struct.new(:status, :reason, keyword_init: true)

  def self.call(video:, explicit_lyrics_allowed:)
    new(video: video, explicit_lyrics_allowed: explicit_lyrics_allowed).call
  end

  def initialize(video:, explicit_lyrics_allowed:)
    @video = video
    @explicit_lyrics_allowed = explicit_lyrics_allowed
  end

  def call
    return review('provider metadata is unavailable') unless @video
    return review('karaoke status is not verified') unless verified_karaoke?
    return reject('explicit lyrics are not allowed at this venue') if explicit? && !@explicit_lyrics_allowed
    return review('explicit lyrics status is unknown') if explicit?.nil?

    eligible('metadata satisfies current queue policy')
  end

  private

  def verified_karaoke?
    @video[:verified_karaoke]
  end

  def explicit?
    @video[:explicit_lyrics]
  end

  def eligible(reason)
    Result.new(status: :eligible, reason: reason)
  end

  def reject(reason)
    Result.new(status: :rejected, reason: reason)
  end

  def review(reason)
    Result.new(status: :review, reason: reason)
  end
end
