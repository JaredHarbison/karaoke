# frozen_string_literal: true

# Creates contextual venue membership records and migrates existing assignments.
class CreateVenueMemberships < ActiveRecord::Migration[7.2]
  def up
    create_table :venue_memberships do |t|
      t.references :venue, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false, default: 2
      t.timestamps
    end

    add_index :venue_memberships, %i[venue_id user_id], unique: true
    add_index :venue_memberships, %i[venue_id role]

    backfill_memberships
  end

  def down
    drop_table :venue_memberships
  end

  private

  def backfill_memberships
    now = connection.quote(Time.current)
    backfill_user_venue_memberships(now)
    backfill_venue_admin_memberships(now)
    backfill_venue_owner_memberships(now)
  end

  def backfill_user_venue_memberships(now)
    execute <<~SQL.squish
      INSERT INTO venue_memberships (venue_id, user_id, role, created_at, updated_at)
      SELECT users.venue_id, users.id, users.role, #{now}, #{now}
      FROM users
      WHERE users.venue_id IS NOT NULL
      ON CONFLICT (venue_id, user_id) DO NOTHING
    SQL
  end

  def backfill_venue_admin_memberships(now)
    execute <<~SQL.squish
      INSERT INTO venue_memberships (venue_id, user_id, role, created_at, updated_at)
      SELECT venue_admins.venue_id, venue_admins.user_id, 1, #{now}, #{now}
      FROM venue_admins
      ON CONFLICT (venue_id, user_id) DO UPDATE
      SET role = CASE WHEN venue_memberships.role = 0 THEN 0 ELSE 1 END,
          updated_at = EXCLUDED.updated_at
    SQL
  end

  def backfill_venue_owner_memberships(now)
    execute <<~SQL.squish
      INSERT INTO venue_memberships (venue_id, user_id, role, created_at, updated_at)
      SELECT venues.id, venues.owner_id, 0, #{now}, #{now}
      FROM venues
      WHERE venues.owner_id IS NOT NULL
      ON CONFLICT (venue_id, user_id) DO UPDATE
      SET role = 0,
          updated_at = EXCLUDED.updated_at
    SQL
  end
end
