module SongQueue
  class Reorder
    class << self
      def pause!(song, spots_back, actor: nil)
        reorder!(song, spots_back, postponed: true, move_to_front: false, override: { actor: actor, action: 'pause' })
      end

      def unpause!(song, actor: nil)
        reorder!(song, 0, postponed: false, move_to_front: true, override: { actor: actor, action: 'unpause' })
      end

      private

      def reorder!(song, spots_back, postponed:, move_to_front:, override:)
        raise ArgumentError unless song.persisted?

        reorder_transaction = lambda do
          Song.transaction do
            reorder_records(song, spots_back, postponed:, move_to_front:, override:)
          end
        end

        if song.event_id.present?
          song.event.with_lock(&reorder_transaction)
        else
          reorder_transaction.call
        end
      end

      def reorder_records(song, spots_back, postponed:, move_to_front:, override:)
        queue = queue_for(song).order(:updated_at, :id).to_a
        current_index = queue.index { |queued_song| queued_song.id == song.id }
        raise ArgumentError unless current_index

        queue.delete(song)
        insertion_index = move_to_front ? 0 : [current_index + spots_back, queue.length].min
        queue.insert(insertion_index, song)

        base_time = Time.current - queue.length.seconds
        queue.each_with_index do |queued_song, index|
          queued_song.update_columns(
            postponed: queued_song.id == song.id ? postponed : queued_song.postponed,
            updated_at: base_time + index.seconds
          )
        end
        record_override(song, override[:actor], override[:action], spots_back)
      end

      def record_override(song, actor, action, spots_back)
        return unless actor && song.event_id

        song.event.song_queue_overrides.create!(song: song, user: actor, action: action, spots_back: spots_back)
      end

      def queue_for(song)
        scope = Song.upcoming
        song.event_id.present? ? scope.where(event_id: song.event_id) : scope.where(event_id: nil)
      end
    end
  end
end
