class AddUserToSongs < ActiveRecord::Migration[7.1]
  def change
    add_reference :songs, :user, null: true, foreign_key: true
    add_index :songs, [:user_id, :created_at]
  end
end
