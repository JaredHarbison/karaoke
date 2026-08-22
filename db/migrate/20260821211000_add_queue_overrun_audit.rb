# frozen_string_literal: true

# Adds the explicit event runtime override and its small audit trail.
class AddQueueOverrunAudit < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :allow_queue_overrun, :boolean, null: false, default: false

    create_table :event_setting_changes do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :setting, null: false
      t.boolean :previous_value, null: false
      t.boolean :new_value, null: false
      t.timestamps
    end

    add_index :event_setting_changes, %i[event_id created_at]
  end
end
