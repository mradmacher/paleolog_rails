class AddAccountIdToRegions < ActiveRecord::Migration
  def change
    add_column :regions, :account_id, :integer
  end
end
