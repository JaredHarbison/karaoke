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
end
