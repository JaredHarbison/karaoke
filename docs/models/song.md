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
  
  t.timestamps
end

add_index :songs, [:venue_id, :created_at]
add_index :songs, [:user_id, :created_at]
```

## Associations

```ruby
belongs_to :venue, optional: true
belongs_to :user, optional: true
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
