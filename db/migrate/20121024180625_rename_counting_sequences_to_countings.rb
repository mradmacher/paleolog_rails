class RenameCountingSequencesToCountings < ActiveRecord::Migration
  def up
    rename_table :counting_sequences, :countings
  end

  def down
    rename_table :countings, :counting_sequences 
  end
end
