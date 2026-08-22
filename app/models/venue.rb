class Venue < ApplicationRecord
  belongs_to :owner, class_name: 'User', optional: true
  has_many :venue_memberships, dependent: :destroy
  has_many :members, through: :venue_memberships, source: :user
  has_many :admin_memberships, -> { where(role: :admin) }, class_name: 'VenueMembership', dependent: :destroy
  has_many :hosts, through: :admin_memberships, source: :user
  has_many :performances, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many :invitations, class_name: 'VenueInvitation', dependent: :destroy
  has_many :event_series, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :themes, dependent: :destroy
  has_many :event_theme_applications, through: :events
  
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }
  
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  after_create :ensure_owner_membership
  before_validation :ensure_presence_token
  
  def add_host(user)
    membership = venue_memberships.find_or_initialize_by(user: user)
    membership.role = :admin unless membership.owner?
    membership.save!
  end

  alias_method :add_admin, :add_host
  
  def remove_host(user)
    membership = venue_memberships.find_by(user: user)
    membership&.destroy if membership&.admin?
  end

  alias_method :remove_admin, :remove_host
  
  def is_admin?(user)
    admin?(user)
  end

  alias_method :is_host?, :is_admin?

  def membership_for(user)
    return unless user

    venue_memberships.find_by(user_id: user.id)
  end

  def owner?(user)
    user.present? && (owner_id == user.id || membership_for(user)&.owner?)
  end

  def admin?(user)
    return false unless user

    membership = membership_for(user)
    return true if membership&.owner? || membership&.admin?

    owner_id == user.id
  end
  
  private

  def ensure_owner_membership
    return unless owner

    venue_memberships.create!(user: owner, role: :owner)
  end
  
  def generate_slug
    self.slug = name.parameterize
  end

  def ensure_presence_token
    self.presence_token ||= SecureRandom.urlsafe_base64(24)
  end
end
