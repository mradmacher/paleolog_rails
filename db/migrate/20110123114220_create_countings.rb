class CreateCountings < ActiveRecord::Migration
  def self.up
    create_table :countings do |t|
      t.references :sample
      t.integer :sequence
    end
  end

  def self.down
    drop_table :countings
  end
end
