class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
      t.boolean :administration
      t.boolean :editing
      t.boolean :commenting
    end
  end

  def self.down
    drop_table :roles
  end
end
