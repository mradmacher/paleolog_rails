class AddLoginToUser < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def self.up
    add_column :users, :login, :string
    User.all.each do |user|
      user.login = user.email
      user.save
    end
  end

  def self.down
    remove_column :users, :login
  end
end
