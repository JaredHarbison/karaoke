class AddTitleToSongs < ActiveRecord::Migration[7.1]
  def change
    add_column :songs, :title, :string
  end
end
