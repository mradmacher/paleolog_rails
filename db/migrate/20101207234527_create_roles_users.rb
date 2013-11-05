class CreateRolesUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base
    has_and_belongs_to_many :roles
  end
  class Role < ActiveRecord::Base
    has_and_belongs_to_many :users
  end
  def self.up
    create_table :roles_users, :id => false do |t|
      t.column :user_id, :integer
      t.column :role_id, :integer
    end
    User.reset_column_information
    User.all.each do |user|
      user.role_ids = [user.role_id]
      user.save
    end
    remove_column :users, :role_id
  end

  def self.down
    add_column :users, :role_id, :integer
    User.reset_column_information
    User.all.each do |user|
      if !user.roles.nil? and !user.roles.empty? 
        user.role_id = user.roles.first.id
        user.save
      end
    end
    drop_table :roles_users
  end
end
