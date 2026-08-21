# frozen_string_literal: true

# Adds the optional event boundary to existing venue queue songs.
class AddEventToSongs < ActiveRecord::Migration[7.1]
  def change
    add_reference :songs, :event, null: true, foreign_key: true, index: true
  end
end
