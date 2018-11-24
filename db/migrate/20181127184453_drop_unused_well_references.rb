class DropUnusedWellReferences < ActiveRecord::Migration
  def change
    remove_column :countings, :well_id
    remove_column :occurrences, :specimen_type
    remove_column :occurrences, :sample_counting_id
  end
end
