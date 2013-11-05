class RemoveSequenceFromSampleCounting < ActiveRecord::Migration
  def up
    remove_column :sample_countings, :sequence
  end

  def down
    add_column :sample_countings, :sequence, :integer
  end
end
