class AddAccountIdToSpecimens < ActiveRecord::Migration
  def change
    add_column :specimens, :account_id, :integer
  end
end
