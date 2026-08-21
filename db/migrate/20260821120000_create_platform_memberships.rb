# frozen_string_literal: true

# Moves application-wide staff access from a boolean flag to an extensible role.
class CreatePlatformMemberships < ActiveRecord::Migration[7.2]
  def up
    create_platform_memberships_table
    copy_platform_admins
    remove_platform_admin_flag
  end

  def create_platform_memberships_table
    create_table :platform_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :role, default: 0, null: false
      t.timestamps
    end
  end

  def copy_platform_admins
    execute <<~SQL
      INSERT INTO platform_memberships (user_id, role, created_at, updated_at)
      SELECT id, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM users
      WHERE platform_admin = TRUE
    SQL
  end

  def remove_platform_admin_flag
    remove_index :users, :platform_admin
    remove_column :users, :platform_admin
  end

  def down
    add_column :users, :platform_admin, :boolean, default: false, null: false
    add_index :users, :platform_admin

    execute <<~SQL
      UPDATE users
      SET platform_admin = TRUE
      WHERE id IN (
        SELECT user_id FROM platform_memberships WHERE role = 0
      )
    SQL

    drop_table :platform_memberships
  end
end
