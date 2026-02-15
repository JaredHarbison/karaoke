class AddVenueToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :venue, null: true, foreign_key: true
  end
end
