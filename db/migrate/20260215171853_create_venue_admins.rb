class CreateVenueAdmins < ActiveRecord::Migration[7.1]
  def change
    create_table :venue_admins do |t|
      t.references :venue, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :venue_admins, [:venue_id, :user_id], unique: true
  end
end
