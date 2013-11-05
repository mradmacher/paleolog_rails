class RemoveImageableTypeFromImages < ActiveRecord::Migration
  def up
    remove_column :images, :imageable_type
  end

  def down
    add_column :images, :imageable_type, :string
  end
end
