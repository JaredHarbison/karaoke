# frozen_string_literal: true

# Stores time-limited event-specific host authority.
class CreateEventHostDelegations < ActiveRecord::Migration[7.1]
  def change
    create_table :event_host_delegations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :delegated_user, null: false, foreign_key: { to_table: :users }
      t.references :delegated_by_user, null: false, foreign_key: { to_table: :users }
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.datetime :revoked_at
      t.timestamps
    end

    add_index :event_host_delegations, %i[event_id starts_at ends_at]
  end
end
