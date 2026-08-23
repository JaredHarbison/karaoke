# frozen_string_literal: true

# Stores the venue-local zone used for event and presence deadlines.
class AddTimeZoneToVenues < ActiveRecord::Migration[7.2]
  def change
    add_column :venues, :time_zone, :string, null: false, default: 'America/New_York'
  end
end
