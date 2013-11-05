class DepthTypeToDecimal < ActiveRecord::Migration
  def self.up
    remove_column :samples, :depth
    add_column :samples, :depth, :decimal
  end

  def self.down
    remove :samples, :depth
    add_column :samples, :depth, :string
  end
end
