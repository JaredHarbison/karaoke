# frozen_string_literal: true

# Persists canonical provider metadata while queue entries remain transitional
# until they are migrated to the planned event-specific Performance model.
class SongCatalog
  def self.metadata_for(url)
    video_id = YoutubeService.extract_video_id(url)
    return unless video_id

    identity = Song.find_by(provider: 'youtube', provider_video_id: video_id)
    return metadata_from_identity(identity, video_id) if identity&.metadata_checked_at && identity.verified_karaoke

    song = cached_queue_song(video_id)
    metadata_from_queue_song(song, video_id) if song
  end

  def self.record!(metadata)
    video_id = metadata[:video_id]
    return unless video_id

    identity = Song.find_or_initialize_by(provider: 'youtube', provider_video_id: video_id)
    identity.assign_attributes(identity_attributes(metadata))
    identity.save!
    identity
  end

  def self.identity_attributes(metadata)
    {
      title: metadata[:title],
      verified_karaoke: metadata[:verified_karaoke] == true,
      explicit_lyrics: metadata[:explicit_lyrics],
      duration_seconds: metadata[:duration_seconds],
      metadata_checked_at: Time.current
    }
  end

  def self.cached_queue_song(video_id)
    Performance.unscoped.where(
      provider: 'youtube', provider_video_id: video_id, metadata_status: 'eligible'
    ).where.not(metadata_checked_at: nil).order(metadata_checked_at: :desc).first
  end

  def self.metadata_from_identity(identity, video_id)
    {
      valid: identity.verified_karaoke,
      video_id: video_id,
      title: identity.title,
      verified_karaoke: identity.verified_karaoke,
      explicit_lyrics: identity.explicit_lyrics,
      duration_seconds: identity.duration_seconds
    }
  end

  def self.metadata_from_queue_song(song, video_id)
    {
      valid: true,
      video_id: video_id,
      title: song.title,
      verified_karaoke: true,
      explicit_lyrics: song.explicit_lyrics,
      duration_seconds: song.duration_seconds
    }
  end

  private_class_method :cached_queue_song, :metadata_from_identity, :metadata_from_queue_song,
                       :identity_attributes
end
