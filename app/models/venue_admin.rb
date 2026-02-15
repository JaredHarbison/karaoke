class VenueAdmin < ApplicationRecord
  belongs_to :venue
  belongs_to :user
  
  validates :venue_id, presence: true, uniqueness: { scope: :user_id, message: "user is already an admin of this venue" }
  validates :user_id, presence: true
end
