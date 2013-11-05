class DropOthers < ActiveRecord::Migration
  def up
    drop_table :others
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
