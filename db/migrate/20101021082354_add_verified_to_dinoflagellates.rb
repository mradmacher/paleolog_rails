class AddVerifiedToDinoflagellates < ActiveRecord::Migration
  class Dinoflagellate < ActiveRecord::Base
  end

  def self.up
    add_column :dinoflagellates, :verified, :boolean
    Dinoflagellate.all.each do |d|
      d.verified = false
      d.save
    end
  end

  def self.down
    remove_column :dinoflagellates, :verified
  end
end
