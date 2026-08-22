# frozen_string_literal: true

# Records a host's event-scoped Fair Queue intervention.
class SongQueueOverride < ApplicationRecord
  belongs_to :event
  belongs_to :performance, class_name: 'Performance', foreign_key: :song_id
  alias song performance
  alias song= performance=
  belongs_to :user

  validates :action, presence: true, inclusion: { in: %w[pause unpause] }
  validate :song_belongs_to_event

  private

  def song_belongs_to_event
    return if song.blank? || event_id == song.event_id

    errors.add(:song, 'must belong to the same event')
  end
end
