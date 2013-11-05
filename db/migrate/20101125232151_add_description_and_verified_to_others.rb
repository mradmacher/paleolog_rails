class AddDescriptionAndVerifiedToOthers < ActiveRecord::Migration
  class Other < ActiveRecord::Base
  end

  def self.up
    add_column :others, :description, :string
    add_column :others, :verified, :boolean
    Other.all.each do |d|
      d.verified = false
      d.save
    end
  end

  def self.down
    remove_column :others, :description
    remove_column :others, :verified
  end
end
