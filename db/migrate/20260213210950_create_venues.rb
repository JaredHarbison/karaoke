class CreateVenues < ActiveRecord::Migration[7.1]
  def change
    create_table :venues do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :location
      t.text :description

      t.timestamps
    end
    
    add_index :venues, :slug, unique: true
  end
end
