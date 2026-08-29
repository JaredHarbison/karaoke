# frozen_string_literal: true

# Adds authenticated event-code check-ins for temporary-host eligibility.
class CreateEventCheckIns < ActiveRecord::Migration[7.2]
  def change
    create_table :event_check_ins do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :checked_in_at, null: false

      t.timestamps
    end

    add_index :event_check_ins, %i[event_id user_id], unique: true
  end
end
