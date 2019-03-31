class AddRankToSamples < ActiveRecord::Migration
  def change
    add_column :samples, :rank, :integer
  end
end
