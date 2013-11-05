class AddMarkerIdToCountings < ActiveRecord::Migration
  def change
    add_column :countings, :marker_id, :integer
  end
end
