class CreateSpecimens < ActiveRecord::Migration
  def self.up
    create_table :specimens do |t|
      t.string :name
      t.boolean :verified
      t.integer :group

      t.text :description
      t.text :age
      t.text :comparison
      t.text :range

      t.timestamps
    end
  end

  def self.down
    drop_table :specimens
  end
end
