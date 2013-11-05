class CreateFields < ActiveRecord::Migration
  def up
    create_table :fields do |t|
      t.string :name
      t.references :group
    end
  end

  def down
    drop_table :fields
  end
end
