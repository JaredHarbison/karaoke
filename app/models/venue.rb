class Venue < ApplicationRecord
  belongs_to :owner, class_name: 'User', optional: true
  has_many :venue_memberships, dependent: :destroy
  has_many :members, through: :venue_memberships, source: :user
  has_many :songs, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many :admin_assignments, class_name: 'VenueAdmin', dependent: :destroy
  has_many :admins, through: :admin_assignments, source: :user
  has_many :invitations, class_name: 'VenueInvitation', dependent: :destroy
  
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }
  
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  after_create :ensure_owner_membership
  
  def add_admin(user)
    admin_assignments.find_or_create_by(user: user)
    membership = venue_memberships.find_or_initialize_by(user: user)
    membership.role = :admin unless membership.owner?
    membership.save!
  end

  alias_method :add_host, :add_admin
  
  def remove_admin(user)
    admin_assignments.find_by(user: user)&.destroy
    membership = venue_memberships.find_by(user: user)
    membership&.destroy if membership&.admin?
  end

  alias_method :remove_host, :remove_admin
  
  def is_admin?(user)
    user.present? && (owner_id == user.id || admins.include?(user))
  end

  alias_method :is_host?, :is_admin?
  
  private

  def ensure_owner_membership
    return unless owner

    venue_memberships.create!(user: owner, role: :owner)
  end
  
  def generate_slug
    self.slug = name.parameterize
  end
end
