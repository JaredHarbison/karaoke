class Venue < ApplicationRecord
  has_many :songs, dependent: :destroy
  has_many :users, dependent: :nullify
  
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }
  
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  
  private
  
  def generate_slug
    self.slug = name.parameterize
  end
end
