class RenameCountingSequenceIdToCountingIdInSampleCountings < ActiveRecord::Migration
  def up
    rename_column :sample_countings, :counting_sequence_id, :counting_id
  end

  def down
    rename_column :sample_countings, :counting_id, :counting_sequence_id
  end
end
