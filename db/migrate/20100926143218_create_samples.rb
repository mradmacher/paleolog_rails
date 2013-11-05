class CreateSamples < ActiveRecord::Migration
  def self.up
    create_table :samples do |t|
      t.string :name
      t.string :depth
      t.references :well

      t.timestamps
    end
  end

  def self.down
    drop_table :samples
  end
end
