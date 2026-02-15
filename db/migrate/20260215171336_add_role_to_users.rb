class AddRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :integer, default: 2, null: false # 0: owner, 1: admin, 2: performer
    add_index :users, :role
  end
end
