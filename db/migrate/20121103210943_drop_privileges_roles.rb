class DropPrivilegesRoles < ActiveRecord::Migration
  def up
    drop_table :privileges_roles
  end

  def down
    create_table :privileges_roles, :id => false do |t|
      t.column :privilege_id, :integer
      t.column :role_id, :integer
    end
  end
end
