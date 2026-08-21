# frozen_string_literal: true

# Connects a user to a venue with contextual authority.
class VenueMembership < ApplicationRecord
  belongs_to :venue
  belongs_to :user

  enum :role, { owner: 0, admin: 1, performer: 2 }

  validates :venue_id, uniqueness: { scope: :user_id }
  validates :user_id, presence: true
end
