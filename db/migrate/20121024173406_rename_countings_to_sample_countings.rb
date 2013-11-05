class RenameCountingsToSampleCountings < ActiveRecord::Migration
  def up
    rename_table :countings, :sample_countings
  end

  def down
    rename_table :sample_countings, :countings
  end
end
