class DropSampleCountings < ActiveRecord::Migration
  def up
    drop_table :sample_countings
  end

  def down
    create_table :sample_countings do |t|
      t.references :sample
      t.references :counting
    end
  end
end
