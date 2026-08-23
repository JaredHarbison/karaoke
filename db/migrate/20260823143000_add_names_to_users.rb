# frozen_string_literal: true

# Adds user-facing identity fields without requiring a destructive backfill.
class AddNamesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
  end
end
