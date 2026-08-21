# frozen_string_literal: true

# Application-wide authorization relationship for a user.
class PlatformMembership < ApplicationRecord
  belongs_to :user

  enum :role, { admin: 0 }

  validates :user_id, presence: true, uniqueness: true
end
