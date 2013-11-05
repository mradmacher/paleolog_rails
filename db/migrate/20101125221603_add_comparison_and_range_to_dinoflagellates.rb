class AddComparisonAndRangeToDinoflagellates < ActiveRecord::Migration
  def self.up
    add_column :dinoflagellates, :comparison, :string
    add_column :dinoflagellates, :range, :string
  end

  def self.down
    remove_column :dinoflagellates, :comparison
    remove_column :dinoflagellates, :range
  end
end
