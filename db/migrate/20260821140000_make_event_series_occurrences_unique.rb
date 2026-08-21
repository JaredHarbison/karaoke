# frozen_string_literal: true

# Prevents duplicate materialization of one series occurrence.
class MakeEventSeriesOccurrencesUnique < ActiveRecord::Migration[7.2]
  def up
    remove_index :events, name: 'index_events_on_event_series_id_and_starts_at'
    add_index :events, %i[event_series_id starts_at], unique: true
  end

  def down
    remove_index :events, name: 'index_events_on_event_series_id_and_starts_at'
    add_index :events, %i[event_series_id starts_at]
  end
end
