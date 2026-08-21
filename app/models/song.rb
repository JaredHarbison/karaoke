class Song < ApplicationRecord
    belongs_to :venue, optional: true
    belongs_to :user, optional: true
    belongs_to :event, optional: true
    
    scope :queued, -> { where( finished: false, skipped: false, postponed: false ) }
    scope :finished, -> { where( finished: true ) }
    scope :upcoming, -> { where( finished: false, skipped: false ) }
    scope :postponed, -> { where( finished: false, postponed: true ) }
    scope :skipped, -> { where( finished: false, skipped: true ) }
    
    validates :performer, presence: true
    validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
    validate :event_belongs_to_venue
    
    # Scope songs to current venue when set
    default_scope { where(venue_id: Current.venue_id) if Current.venue_id.present? }

  private

    def event_belongs_to_venue
      return unless event && venue_id != event.venue_id

      errors.add(:event, 'must belong to the same venue')
    end
end
