# Song Model

## Schema

```ruby
create_table :songs do |t|
  t.string :category
  t.string :performer
  t.string :url
  t.boolean :postponed, default: false
  t.boolean :finished, default: false
  t.boolean :skipped, default: false
  
  # Multi-tenancy
  t.references :venue, foreign_key: true, null: true
  
  # Ownership
  t.references :user, foreign_key: true, null: true

  # Transitional provider admission metadata
  t.string :provider, null: false, default: 'youtube'
  t.string :provider_video_id
  t.string :metadata_status, null: false, default: 'legacy'
  t.boolean :explicit_lyrics
  t.integer :duration_seconds
  t.integer :effective_duration_seconds
  t.string :duration_source
  t.datetime :metadata_checked_at
  
  t.timestamps
end

add_index :songs, [:venue_id, :created_at]
add_index :songs, [:user_id, :created_at]
```

## Associations

```ruby
belongs_to :venue, optional: true
belongs_to :user, optional: true
belongs_to :event, optional: true
```

## Scopes

```ruby
scope :finished, -> { where(finished: true) }
scope :upcoming, -> { where(finished: false, skipped: false) }
scope :postponed, -> { where(finished: false, postponed: true) }
scope :skipped, -> { where(finished: false, skipped: true) }
```

## Validations

```ruby
validates :performer, presence: true
validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
```

Live event queue entries pass provider metadata through `SongAdmissionPolicy`.
Unknown or unverified metadata is held for review. Known duration is preferred;
missing duration uses the event queue's average of known durations, with a safe
fallback when none are available. These fields are transitional until the
canonical `Song`/`Performance` boundary is migrated.

## Multi-tenancy

- Scoped to `Current.venue_id` by default
- `default_scope { where(venue_id: Current.venue_id) if Current.venue_id.present? }`

## Status Flags

| Flag        | Meaning                      | Usage                            |
| ----------- | ---------------------------- | -------------------------------- |
| `finished`  | Song has been performed      | Set when "Finish" button clicked |
| `skipped`   | Song temporarily postponed   | Toggled by "Skip" button         |
| `postponed` | User unavailable to perform  | Not actively used yet            |

## States

- **Upcoming**: not finished, not skipped
- **Skipped**: not finished, skipped
- **Postponed**: not finished, postponed
- **Finished**: finished
