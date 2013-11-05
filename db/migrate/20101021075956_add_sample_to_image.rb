class AddSampleToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :sample_id, :integer
  end

  def self.down
    remove_column :images, :sample_id
  end
end
