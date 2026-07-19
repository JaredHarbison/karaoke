class VenueInvitation < ApplicationRecord
  belongs_to :venue
  belongs_to :invited_by, class_name: 'User'

  before_validation :assign_token, on: :create

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true

  scope :pending, -> { where(accepted_at: nil).where('expires_at > ?', Time.current) }

  def expired?
    expires_at <= Time.current
  end

  def pending?
    accepted_at.nil? && !expired?
  end

  def accept!(user)
    raise ActiveRecord::RecordInvalid, self unless pending? && email.casecmp?(user.email)

    transaction do
      venue.add_admin(user)
      update!(accepted_at: Time.current)
    end
  end

  private

  def assign_token
    self.token ||= SecureRandom.urlsafe_base64(32)
    self.expires_at ||= 14.days.from_now
    self.email = email.to_s.downcase.strip
  end
end
