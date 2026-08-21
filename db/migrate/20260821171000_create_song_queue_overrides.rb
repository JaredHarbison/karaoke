# frozen_string_literal: true

# Stores durable event-scoped Fair Queue overrides.
class CreateSongQueueOverrides < ActiveRecord::Migration[7.1]
  def change
    create_table :song_queue_overrides do |t|
      t.references :event, null: false, foreign_key: true
      t.references :song, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.integer :spots_back
      t.timestamps
    end

    add_index :song_queue_overrides, %i[event_id created_at]
  end
end
