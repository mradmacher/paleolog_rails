class CreateWells < ActiveRecord::Migration
  def self.up
    create_table :wells do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :wells
  end
end
