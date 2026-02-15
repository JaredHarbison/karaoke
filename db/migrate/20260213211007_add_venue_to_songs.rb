class AddVenueToSongs < ActiveRecord::Migration[7.1]
  def change
    add_reference :songs, :venue, null: true, foreign_key: true
    add_index :songs, [:venue_id, :created_at]
  end
end
