# frozen_string_literal: true

# Adds the event-level Fair Queue setting.
class AddFairQueueEnabledToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :fair_queue_enabled, :boolean, null: false, default: true
  end
end
