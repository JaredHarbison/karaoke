class User < ApplicationRecord
  belongs_to :venue, optional: true
  has_many :performances, dependent: :nullify
  has_many :owned_venues, class_name: 'Venue', foreign_key: 'owner_id', dependent: :nullify
  has_many :venue_memberships, dependent: :destroy
  has_many :member_venues, through: :venue_memberships, source: :venue
  has_many :platform_memberships, dependent: :destroy
  has_many :sent_venue_invitations, class_name: 'VenueInvitation', foreign_key: :invited_by_id, dependent: :destroy
  has_many :event_host_delegations, dependent: :destroy, foreign_key: :delegated_user_id
  has_many :granted_event_host_delegations,
           class_name: 'EventHostDelegation', dependent: :restrict_with_exception,
           foreign_key: :delegated_by_user_id
  has_many :event_presence_sessions, dependent: :restrict_with_exception, foreign_key: :created_by_user_id

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  validate :password_complexity, if: :password_required?

  def self.from_omniauth(auth)
    email = auth.info.email.to_s.downcase
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    user = find_or_initialize_by(email: email)
    user.provider = auth.provider if user.provider.blank?
    user.uid = auth.uid if user.uid.blank?
    user.password = Devise.friendly_token[0, 20] if user.new_record?
    user.save!

    user
  end
  
  def owner_of?(venue)
    venue.owner_id == id
  end
  
  def admin_of?(venue)
    venue.admin?(self)
  end

  def venue_operator?
    venue_memberships.where(role: %i[owner admin]).exists? ||
      owned_venues.exists?
  end

  def platform_operator?
    platform_memberships.where(role: :admin).exists?
  end

  def display_name
    email.to_s.split('@').first.tr('._-', ' ').titleize
  end

  private

  def password_complexity
    return if password.blank? || (password.match?(/[a-z]/) && password.match?(/[A-Z]/) && password.match?(/[0-9]/))

    errors.add(:password, 'must include uppercase, lowercase, and a number')
  end
end
