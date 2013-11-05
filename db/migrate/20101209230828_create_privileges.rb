class CreatePrivileges < ActiveRecord::Migration
  class Privilege < ActiveRecord::Base
  end

  def self.up
    create_table :privileges do |t|
      t.string :name
    end
    Privilege.reset_column_information
    [:administrating, :viewing, :editing, :commenting].each do |priv|
      p = Privilege.new( :name => priv )
      p.save
    end
  end

  def self.down
    drop_table :privileges
  end
end
