# frozen_string_literal: true

# Adds reusable venue themes and event-specific application windows.
class CreateThemesAndEventThemeApplications < ActiveRecord::Migration[7.1]
  def change
    create_themes
    create_event_theme_applications
  end

  private

  def create_themes
    create_table :themes do |t|
      t.references :venue, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.jsonb :rules, null: false, default: {}
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :themes, [:venue_id, :name], unique: true
  end

  def create_event_theme_applications
    create_table :event_theme_applications do |t|
      t.references :event, null: false, foreign_key: true
      t.references :theme, null: false, foreign_key: true
      t.datetime :starts_at
      t.datetime :ends_at
      t.timestamps
    end

    add_index :event_theme_applications, [:event_id, :theme_id], unique: true
  end
end
