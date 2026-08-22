# frozen_string_literal: true

# Stores event-time theme admission state until the Performance migration.
class AddThemeAdmissionToSongs < ActiveRecord::Migration[7.2]
  def change
    add_reference :songs, :theme_application, foreign_key: { to_table: :event_theme_applications }
    add_column :songs, :theme_admission_status, :string, null: false, default: 'not_applicable'
    add_column :songs, :theme_admission_reason, :string
    add_reference :songs, :theme_reviewed_by, foreign_key: { to_table: :users }
    add_column :songs, :theme_reviewed_at, :datetime

    add_index :songs, %i[event_id theme_admission_status]
  end
end
