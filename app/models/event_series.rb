# frozen_string_literal: true

# Reusable recurrence intent for venue events.
class EventSeries < ApplicationRecord
  belongs_to :venue
  has_many :events, dependent: :nullify

  validates :name, :recurrence_rule, :starts_at, presence: true
  validates :ends_at, comparison: { greater_than: :starts_at }, allow_nil: true
end
