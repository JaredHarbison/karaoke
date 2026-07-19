class User < ApplicationRecord
  belongs_to :venue, optional: true
  has_many :songs, dependent: :nullify
  has_many :owned_venues, class_name: 'Venue', foreign_key: 'owner_id', dependent: :nullify
  has_many :admin_for_venues, class_name: 'VenueAdmin', dependent: :destroy
  has_many :venues_as_admin, through: :admin_for_venues, source: :venue
  has_many :sent_venue_invitations, class_name: 'VenueInvitation', foreign_key: :invited_by_id, dependent: :destroy

  enum role: { owner: 0, admin: 1, performer: 2 }
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  validate :password_complexity, if: :password_required?

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end
  
  def owner_of?(venue)
    venue.owner_id == id
  end
  
  def admin_of?(venue)
    owner_of?(venue) || venues_as_admin.include?(venue)
  end

  private

  def password_complexity
    return if password.blank? || (password.match?(/[a-z]/) && password.match?(/[A-Z]/) && password.match?(/[0-9]/))

    errors.add(:password, 'must include uppercase, lowercase, and a number')
  end
end
