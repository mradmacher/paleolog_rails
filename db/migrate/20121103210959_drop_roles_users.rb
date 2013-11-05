class DropRolesUsers < ActiveRecord::Migration
  def up
    drop_table :roles_users
  end

  def down
    create_table :roles_users, :id => false do |t|
      t.column :user_id, :integer
      t.column :role_id, :integer
    end
  end
end
