class AddWeightToSamples < ActiveRecord::Migration
  def change
    add_column :samples, :weight, :decimal
  end
end
