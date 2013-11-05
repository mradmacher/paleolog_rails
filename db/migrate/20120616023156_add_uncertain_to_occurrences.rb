class AddUncertainToOccurrences < ActiveRecord::Migration
  def change
    add_column :occurrences, :uncertain, :boolean, :default => false
  end
end
