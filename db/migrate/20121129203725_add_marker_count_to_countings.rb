class AddMarkerCountToCountings < ActiveRecord::Migration
  def change
    add_column :countings, :marker_count, :integer
  end
end
