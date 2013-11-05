class CreateSampleSpecimen < ActiveRecord::Migration
  def self.up
    create_table :sample_specimens do |t|
      t.references :specimen, :polymorphic => true 
      t.references :sample
      t.integer :quantity
    end
  end

  def self.down
    drop_table :sample_specimens
  end
end
