class AddCountingAndSampleToOccurrences < ActiveRecord::Migration
  def change
    add_column :occurrences, :sample_id, :integer
    add_column :occurrences, :counting_id, :integer
  end
end
