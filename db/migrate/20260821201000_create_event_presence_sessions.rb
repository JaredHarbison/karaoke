# frozen_string_literal: true

# Stores expiring, revocable event presence bearer sessions.
class CreateEventPresenceSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :event_presence_sessions do |t|
      t.references :event, null: false, foreign_key: true
      t.references :created_by_user, null: false, foreign_key: { to_table: :users }
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.timestamps
    end

    add_index :event_presence_sessions, :token, unique: true
    add_index :event_presence_sessions, %i[event_id expires_at]
  end
end
