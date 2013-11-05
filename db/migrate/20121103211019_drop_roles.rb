class DropRoles < ActiveRecord::Migration
  def up
    drop_table :roles
  end

  def down
    create_table :roles do |t|
      t.string :name
      t.boolean :administration
      t.boolean :editing
      t.boolean :commenting
    end
  end
end
