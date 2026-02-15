class AddPublicToVenues < ActiveRecord::Migration[7.1]
  def change
    add_column :venues, :public, :boolean, default: true
    add_index :venues, :public
  end
end
