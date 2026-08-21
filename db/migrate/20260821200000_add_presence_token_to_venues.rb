# frozen_string_literal: true

# Adds a permanent bearer token for venue QR navigation.
class AddPresenceTokenToVenues < ActiveRecord::Migration[7.1]
  def change
    add_column :venues, :presence_token, :string
    add_index :venues, :presence_token, unique: true

    reversible do |direction|
      direction.up do
        Venue.reset_column_information
        Venue.find_each { |venue| venue.update_columns(presence_token: SecureRandom.urlsafe_base64(24)) }
      end
    end
  end
end
