class CreateChoices < ActiveRecord::Migration
  def up
    create_table :choices do |t|
      t.string :name
      t.references :field
    end
  end

  def down
    drop_table :choices
  end
end
