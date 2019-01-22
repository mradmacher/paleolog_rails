class DropRangeAndComparison < ActiveRecord::Migration
  def change
    remove_column :specimens, :range
    remove_column :specimens, :comparison
  end
end
