# frozen_string_literal: true

# Reuses validated provider metadata without yet migrating queue entries to
# the planned canonical Song and event-specific Performance boundary.
class SongCatalog
  def self.metadata_for(url)
    video_id = YoutubeService.extract_video_id(url)
    return unless video_id

    song = cached_song(video_id)
    return unless song

    metadata_from(song, video_id)
  end

  def self.cached_song(video_id)
    Song.unscoped.where(
      provider: 'youtube', provider_video_id: video_id, metadata_status: 'eligible'
    ).where.not(metadata_checked_at: nil).order(metadata_checked_at: :desc).first
  end

  def self.metadata_from(song, video_id)
    {
      valid: true,
      video_id: video_id,
      title: song.title,
      verified_karaoke: true,
      explicit_lyrics: song.explicit_lyrics,
      duration_seconds: song.duration_seconds
    }
  end

  private_class_method :cached_song, :metadata_from
end
