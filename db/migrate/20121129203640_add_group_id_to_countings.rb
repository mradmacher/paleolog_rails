class AddGroupIdToCountings < ActiveRecord::Migration
  def change
    add_column :countings, :group_id, :integer
  end
end
