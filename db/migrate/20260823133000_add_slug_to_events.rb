# frozen_string_literal: true

# Adds stable, venue-scoped identifiers for user-facing event URLs.
class AddSlugToEvents < ActiveRecord::Migration[7.2]
  def up
    add_column :events, :slug, :string
    backfill_slugs
    change_column_null :events, :slug, false
    add_index :events, %i[venue_id slug], unique: true
  end

  def down
    remove_index :events, column: %i[venue_id slug]
    remove_column :events, :slug
  end

  private

  def backfill_slugs
    event_record_class.find_each do |event|
      base = event.name.to_s.parameterize.presence || "event-#{event.id}"
      slug = base
      suffix = 2
      while event_record_class.where(venue_id: event.venue_id, slug: slug).exists?
        slug = "#{base}-#{suffix}"
        suffix += 1
      end
      event.update_columns(slug: slug)
    end
  end

  def event_record_class
    @event_record_class ||= Class.new(ActiveRecord::Base) do
      self.table_name = 'events'
    end
  end
end
