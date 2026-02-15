# Venue Model

## Schema

```ruby
create_table :venues do |t|
  t.string :name, null: false
  t.string :slug, null: false
  t.string :location
  t.text :description

  t.timestamps
end

add_index :venues, :slug, unique: true
```

## Associations

```ruby
has_many :songs, dependent: :destroy
has_many :users, dependent: :nullify
```

## Validations

```ruby
validates :name, presence: true
validates :slug, presence: true, uniqueness: true, 
  format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }

before_validation :generate_slug, if: -> { slug.blank? && name.present? }
```

## Multi-tenancy

Venues enable multi-tenant functionality:
- Each venue is a separate karaoke location
- Songs and users are scoped to venues
- Access via slug in URL: `?venue_slug=venue-name`

## Slug Generation

Slugs are auto-generated from the venue name and parameterized:
```ruby
Venue.create!(name: "Joe's Bar")
# slug automatically becomes "joes-bar"
```

## Accessing a Venue

**URL parameter approach:**
```
http://localhost:3000?venue_slug=joes-bar
```

**Console:**
```ruby
Venue.find_by(slug: "joes-bar")
```
