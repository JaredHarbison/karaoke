# frozen_string_literal: true

module SongQueue
  # Orders one event queue by completed turns, then stable queue position.
  class FairOrder
    def initialize(songs, event:)
      @songs = songs.to_a
      @event = event
      @performer_labels_by_user = performer_labels_by_user
    end

    def call
      completed_turns, turns_in_queue, remaining = queue_state
      ordered = []

      until remaining.empty?
        index = next_index(remaining, completed_turns, turns_in_queue)
        song = remaining.delete_at(index)
        ordered << song
        turns_in_queue[performer_key(song)] += 1
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
      performer = performer_key(song)
      completed = completed_turns.fetch(performer, 0)
      [completed + turns_in_queue[performer], completed, song.updated_at, song.id]
    end

    def completed_turns_by_performer
      finished_songs = Song.unscoped.where(event_id: @event.id, finished: true, skipped: false)
      finished_songs.pluck(:user_id, :performer).each_with_object(Hash.new(0)) do |(user_id, performer), counts|
        counts[performer_key(user_id: user_id, performer: performer)] += 1
      end
    end

    def performer_key(song = nil, user_id: song&.user_id, performer: song&.performer)
      return "user:#{user_id}" if user_id && @performer_labels_by_user.fetch(user_id, []).length > 1

      "name:#{performer.to_s.downcase}"
    end

    def performer_labels_by_user
      labels = Hash.new { |labels_by_user, user_id| labels_by_user[user_id] = [] }
      songs = Song.unscoped.where(event_id: @event.id).pluck(:user_id, :performer)
      songs.each do |user_id, performer|
        next unless user_id

        normalized = performer.to_s.downcase
        labels[user_id] << normalized unless labels[user_id].include?(normalized)
      end
      labels
    end
  end
end
