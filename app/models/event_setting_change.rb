# frozen_string_literal: true

# Audits privileged event setting changes.
class EventSettingChange < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :setting, presence: true
  validates :previous_value, :new_value, inclusion: { in: [true, false] }
end
