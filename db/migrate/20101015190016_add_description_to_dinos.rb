class AddDescriptionToDinos < ActiveRecord::Migration
  def self.up
    add_column :dinos, :description, :string
  end

  def self.down
    remove_column :dinos, :description
  end
end
