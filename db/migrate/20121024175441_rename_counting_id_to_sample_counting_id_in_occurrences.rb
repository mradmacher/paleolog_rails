class RenameCountingIdToSampleCountingIdInOccurrences < ActiveRecord::Migration
  def up
    rename_column :occurrences, :counting_id, :sample_counting_id
  end

  def down
    rename_column :occurrences, :sample_counting_id, :counting_id
  end
end
