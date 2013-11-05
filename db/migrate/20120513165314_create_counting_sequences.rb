class CreateCountingSequences < ActiveRecord::Migration
  def change
    create_table :counting_sequences do |t|
      t.string :name
			t.references :well
    end
  end
end
