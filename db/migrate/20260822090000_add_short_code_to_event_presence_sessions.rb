# frozen_string_literal: true

# Adds a readable performer-facing credential alongside the bearer token.
class AddShortCodeToEventPresenceSessions < ActiveRecord::Migration[7.2]
  def change
    add_column :event_presence_sessions, :short_code, :string
    EventPresenceSession.reset_column_information
    EventPresenceSession.find_each do |presence_session|
      presence_session.update_columns(short_code: SecureRandom.alphanumeric(6).upcase)
    end
    change_column_null :event_presence_sessions, :short_code, false
    add_index :event_presence_sessions, :short_code, unique: true
  end
end
