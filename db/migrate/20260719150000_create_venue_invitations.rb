class CreateVenueInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :venue_invitations do |t|
      t.references :venue, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :accepted_at
      t.datetime :expires_at, null: false
      t.timestamps
    end

    add_index :venue_invitations, :token, unique: true
    add_index :venue_invitations, [:venue_id, :email]
  end
end
