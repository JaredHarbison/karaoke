# frozen_string_literal: true

# Allows one reusable theme to be scheduled in separate, non-overlapping event windows.
class AllowRepeatedEventThemeApplications < ActiveRecord::Migration[7.2]
  def change
    remove_index :event_theme_applications, column: %i[event_id theme_id]
    add_index :event_theme_applications, %i[event_id theme_id]
  end
end
