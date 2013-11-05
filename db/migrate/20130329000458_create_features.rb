class CreateFeatures < ActiveRecord::Migration
  def up
    create_table :features do |t|
      t.references :specimen
      t.references :choice
    end
  end

  def down
    drop_table :features
  end
end
