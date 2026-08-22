# frozen_string_literal: true

# Tracks short-lived event access-code attempts across application processes.
class CreateEventPresenceAttempts < ActiveRecord::Migration[7.2]
  def change
    create_table :event_presence_attempts do |t|
      t.string :fingerprint, null: false
      t.datetime :window_started_at, null: false
      t.integer :attempts, null: false, default: 0
      t.timestamps
    end

    add_index :event_presence_attempts, %i[fingerprint window_started_at],
              unique: true,
              name: 'index_event_presence_attempts_on_fingerprint_and_window'
  end
end
