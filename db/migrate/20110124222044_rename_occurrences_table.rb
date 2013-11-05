class RenameOccurrencesTable < ActiveRecord::Migration
  def self.up
    rename_table 'sample_specimens', 'occurrences'
  end

  def self.down
    rename_table 'occurrences', 'sample_specimens' 
  end
end
