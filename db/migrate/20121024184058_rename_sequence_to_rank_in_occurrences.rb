class RenameSequenceToRankInOccurrences < ActiveRecord::Migration
  def up
    rename_column :occurrences, :sequence, :rank
  end

  def down
    rename_column :occurrences, :rank, :sequence
  end
end
