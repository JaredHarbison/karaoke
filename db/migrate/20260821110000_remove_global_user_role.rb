# frozen_string_literal: true

# Replaces the obsolete venue-wide role with a narrowly scoped platform flag.
class RemoveGlobalUserRole < ActiveRecord::Migration[7.2]
  def up
    add_column :users, :platform_admin, :boolean, default: false, null: false
    add_index :users, :platform_admin
    remove_index :users, :role
    remove_column :users, :role
  end

  def down
    remove_index :users, :platform_admin
    remove_column :users, :platform_admin
    add_column :users, :role, :integer, default: 2, null: false
    add_index :users, :role
  end
end
