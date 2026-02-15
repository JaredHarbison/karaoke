class Venue < ApplicationRecord
  belongs_to :owner, class_name: 'User', optional: true
  has_many :songs, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many :admin_assignments, class_name: 'VenueAdmin', dependent: :destroy
  has_many :admins, through: :admin_assignments, source: :user
  
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }
  
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  
  def add_admin(user)
    admin_assignments.find_or_create_by(user: user)
  end
  
  def remove_admin(user)
    admin_assignments.find_by(user: user)&.destroy
  end
  
  def is_admin?(user)
    owner_id == user.id || admins.include?(user)
  end
  
  private
  
  def generate_slug
    self.slug = name.parameterize
  end
end
