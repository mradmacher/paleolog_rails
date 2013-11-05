class CreateGroups < ActiveRecord::Migration
  class Group < ActiveRecord::Base
  end

  def self.up
    create_table :groups do |t|
      t.string :name
    end
    Group.reset_column_information
    Group.create( :name => 'Dinoflagellate' )
    Group.create( :name => 'Other' )
  end

  def self.down
    drop_table :groups
  end
end
