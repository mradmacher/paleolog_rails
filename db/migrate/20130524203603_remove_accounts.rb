class RemoveAccounts < ActiveRecord::Migration
  def up
    remove_column :specimens, :account_id
    remove_column :regions, :account_id
    drop_table :account_participations
    drop_table :accounts
  end

  def down
    create_table :accounts do |t|
      t.string :name
      t.string :subdomain
      t.timestamps
    end

    create_table :account_participations do |t|
      t.references :account
      t.references :user
      t.boolean :manager, :default => false
      t.timestamps
    end

    add_column :regions, :account_id, :integer
    add_column :specimens, :account_id, :integer
  end
end
