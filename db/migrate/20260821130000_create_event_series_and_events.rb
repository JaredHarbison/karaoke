# frozen_string_literal: true

# Adds venue-scoped recurring-series intent and independently editable events.
class CreateEventSeriesAndEvents < ActiveRecord::Migration[7.2]
  def change
    create_event_series_table
    create_events_table
    add_event_indexes
  end

  def create_event_series_table
    create_table :event_series do |t|
      t.references :venue, null: false, foreign_key: true
      t.string :name, null: false
      t.string :recurrence_rule, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.string :time_zone, null: false, default: 'UTC'
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end

  def create_events_table
    create_table :events do |t|
      t.references :venue, null: false, foreign_key: true
      t.references :event_series, foreign_key: true
      t.string :name, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end

  def add_event_indexes
    add_index :event_series, %i[venue_id active]
    add_index :events, %i[venue_id starts_at]
    add_index :events, %i[event_series_id starts_at]
  end
end
