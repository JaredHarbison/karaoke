# User Model

## Schema

```ruby
create_table :users do |t|
  t.string :email, default: "", null: false
  t.string :encrypted_password, default: "", null: false
  t.string :reset_password_token
  t.datetime :reset_password_sent_at
  t.datetime :remember_created_at
  
  # OAuth fields
  t.string :provider
  t.string :uid
  
  # Multi-tenancy
  t.references :venue, foreign_key: true, null: true
  
  t.timestamps
end

add_index :users, :email, unique: true
add_index :users, :reset_password_token, unique: true
add_index :users, [:provider, :uid], unique: true
```

## Associations

```ruby
belongs_to :venue, optional: true
has_many :songs, dependent: :nullify
```

## Authentication

- **Devise modules**: database_authenticatable, registerable, recoverable, rememberable, validatable, omniauthable
- **OAuth providers**: google_oauth2
- **Method**: `User.from_omniauth(auth)` creates or finds user from Google OAuth

## Multi-tenancy

- Users belong to a venue (optional for legacy data)
- Scoped to current venue via `Current.user` context attribute

## Key Methods

### `from_omniauth(auth)`

Creates or finds a user from OAuth credentials.

```ruby
User.from_omniauth(auth_hash)
# Returns: User instance with provider and uid set
```
