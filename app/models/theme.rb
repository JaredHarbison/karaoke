# frozen_string_literal: true

# Reusable theme definition owned by one venue.
class Theme < ApplicationRecord
  belongs_to :venue
  has_many :event_theme_applications, dependent: :destroy
  has_many :events, through: :event_theme_applications

  validates :name, presence: true, uniqueness: { scope: :venue_id }
end
