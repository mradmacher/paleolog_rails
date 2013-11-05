class AddAgeToDinoflagellates < ActiveRecord::Migration
  def self.up
    add_column :dinoflagellates, :age, :string
  end

  def self.down
    remove_column :dinoflagellates, :age
  end
end
