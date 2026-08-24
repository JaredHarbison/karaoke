module SongHelper
  def link_to_edit(song)
    link_to(edit_song_path(song), class: "song-action btn-discreet") do
      render partial: "components/icons/edit"
    end
  end

  def performer_song_for_current_user?(song)
    return false unless current_user.present?

    song.user == current_user || song.performer.to_s.casecmp(current_user.display_name.to_s).zero?
  end

  def queue_performer_name(song)
    name = song.user&.display_name.presence || song.performer.to_s
    parts = name.split
    return name if parts.length < 2

    "#{parts[0...-1].join(' ')} #{parts.last.first.upcase}."
  end
end
