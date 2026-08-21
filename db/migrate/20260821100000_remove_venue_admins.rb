# frozen_string_literal: true

# Removes the compatibility table after preserving its admin assignments.
class RemoveVenueAdmins < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      INSERT INTO venue_memberships (venue_id, user_id, role, created_at, updated_at)
      SELECT venue_id, user_id, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM venue_admins
      ON CONFLICT (venue_id, user_id) DO NOTHING
    SQL

    drop_table :venue_admins
  end

  def down
    create_legacy_table
    restore_legacy_admins
  end

  private

  def create_legacy_table
    create_table :venue_admins do |t|
      t.references :venue, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :venue_admins, %i[venue_id user_id], unique: true
  end

  def restore_legacy_admins
    execute <<~SQL
      INSERT INTO venue_admins (venue_id, user_id, created_at, updated_at)
      SELECT venue_id, user_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM venue_memberships
      WHERE role = 1
    SQL
  end
end
