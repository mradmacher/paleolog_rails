class DropDinoflagellates < ActiveRecord::Migration
  def up
    drop_table :dinoflagellates
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
