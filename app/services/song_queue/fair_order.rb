# frozen_string_literal: true

module SongQueue
  # Orders one event queue by completed turns, then stable queue position.
  class FairOrder
    def initialize(songs, event:)
      @songs = songs.to_a
      @event = event
    end

    def call
      completed_turns, turns_in_queue, remaining = queue_state
      ordered = []

      until remaining.empty?
        index = next_index(remaining, completed_turns, turns_in_queue)
        song = remaining.delete_at(index)
        ordered << song
        turns_in_queue[song.performer.to_s.downcase] += 1
      end

      ordered
    end

    private

    def queue_state
      [completed_turns_by_performer, Hash.new(0), @songs.sort_by { |song| [song.updated_at, song.id] }]
    end

    def next_index(remaining, completed_turns, turns_in_queue)
      remaining.each_index.min_by do |candidate_index|
        fairness_key(remaining[candidate_index], completed_turns, turns_in_queue)
      end
    end

    def fairness_key(song, completed_turns, turns_in_queue)
      performer = song.performer.to_s.downcase
      [completed_turns[performer] + turns_in_queue[performer], completed_turns[performer], song.updated_at, song.id]
    end

    def completed_turns_by_performer
      counts = Song.unscoped.where(event_id: @event.id, finished: true).group(:performer).count
      counts.transform_keys { |key| key.to_s.downcase }
    end
  end
end
