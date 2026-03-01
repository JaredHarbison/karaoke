
# Current Context

## Purpose

`Current` is a Rails `ActiveSupport::CurrentAttributes` that holds request-scoped context for the current venue and user.

## Source

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :venue, :venue_id, :user

  def venue_id
    venue&.id
  end
end
```

## Usage

### Setting Context

In `ApplicationController`:

```ruby
before_action :set_current_venue
before_action :set_current_user

private

    end
  venue_slug = params[:venue_slug] || session[:venue_slug]
  if venue_slug.present?
    Current.venue = Venue.find_by(slug: venue_slug)
    session[:venue_slug] = venue_slug if Current.venue
  end
end


  Current.user = current_user if user_signed_in?
end
```

### Using Context

In models and controllers:

```ruby
# Get current venue
Current.venue      # Returns Venue instance
Current.venue_id   # Returns venue ID

# Get current user
Current.user       # Returns User instance
```

### Scoping Queries

In Song model:

```ruby
default_scope { where(venue_id: Current.venue_id) if Current.venue_id.present? }
```

## Thread Safety

`ActiveSupport::CurrentAttributes` handles thread safety automatically. Each request gets its own context.

## Persistence

Context is cleared at the end of each HTTP request automatically.
