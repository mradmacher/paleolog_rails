class CreateDinos < ActiveRecord::Migration
  def self.up
    create_table :dinos do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :dinos
  end
end
