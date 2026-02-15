class Current < ActiveSupport::CurrentAttributes
  attribute :venue, :venue_id, :user
  
  def venue_id
    venue&.id
  end
end
