class AddEfToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :ef, :string, :size => 8
  end

  def self.down
    remove_column :images, :ef
  end
end
