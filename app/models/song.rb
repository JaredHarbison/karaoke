class Song < ApplicationRecord
    DEFAULT_DURATION_SECONDS = 180
    QUEUE_ELIGIBLE_THEME_STATUSES = %w[not_applicable eligible released].freeze

    belongs_to :venue, optional: true
    belongs_to :user, optional: true
    belongs_to :event, optional: true
    belongs_to :song_identity, optional: true
    belongs_to :theme_application, class_name: 'EventThemeApplication', optional: true
    belongs_to :theme_reviewed_by, class_name: 'User', optional: true
    
    scope :queued, -> { where(finished: false, skipped: false, postponed: false).queue_eligible }
    scope :finished, -> { where( finished: true ) }
    scope :upcoming, -> { where(finished: false, skipped: false).queue_eligible }
    scope :postponed, -> { where( finished: false, postponed: true ) }
    scope :skipped, -> { where( finished: false, skipped: true ) }
    scope :queue_eligible, -> { where(theme_admission_status: QUEUE_ELIGIBLE_THEME_STATUSES) }
    scope :theme_review, -> { where(theme_admission_status: 'review') }
    
    validates :performer, presence: true
    validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
    enum :metadata_status, { legacy: 'legacy', eligible: 'eligible', review: 'review', rejected: 'rejected' }, prefix: true
    validate :event_belongs_to_venue
    validates :submission_token, uniqueness: true, allow_nil: true
    
    # Scope songs to current venue when set
    default_scope { where(venue_id: Current.venue_id) if Current.venue_id.present? }

    after_initialize :generate_submission_token, if: :new_record?

  private

    def event_belongs_to_venue
      if event_id.present? && event.nil?
        errors.add(:event, 'is not available')
        return
      end

      return unless event && venue_id != event.venue_id

      errors.add(:event, 'must belong to the same venue')
    end

    def generate_submission_token
      self.submission_token ||= SecureRandom.uuid
    end

  public

    def known_duration_average
      return unless event_id

      Song.unscoped.where(event_id: event_id).where.not(duration_seconds: nil).average(:duration_seconds)&.round
    end
end
