module SongQueue
  class Reorder
    class << self
      def pause!(song, spots_back)
        reorder!(song, spots_back, postponed: true, move_to_front: false)
      end

      def unpause!(song)
        reorder!(song, 0, postponed: false, move_to_front: true)
      end

      private

      def reorder!(song, spots_back, postponed:, move_to_front:)
        raise ArgumentError unless song.persisted?

        Song.transaction do
          queue = Song.upcoming.order(:updated_at, :id).to_a
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
        end
      end
    end
  end
end
