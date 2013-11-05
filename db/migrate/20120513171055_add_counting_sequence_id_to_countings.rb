class AddCountingSequenceIdToCountings < ActiveRecord::Migration
  def change
		add_column :countings, :counting_sequence_id, :integer
  end
end
