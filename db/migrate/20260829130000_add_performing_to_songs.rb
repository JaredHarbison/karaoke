# frozen_string_literal: true

# Adds persistent state for the one performance currently being played.
class AddPerformingToSongs < ActiveRecord::Migration[7.2]
  def change
    add_column :songs, :performing, :boolean, default: false, null: false
    add_index :songs, [:event_id, :performing], where: 'finished = false AND skipped = false'
  end
end
