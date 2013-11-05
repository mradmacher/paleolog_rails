class AddDinoIdToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :dino_id, :integer
  end

  def self.down
    remove_column :images, :dino_id
  end
end
