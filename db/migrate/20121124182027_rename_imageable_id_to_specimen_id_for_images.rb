class RenameImageableIdToSpecimenIdForImages < ActiveRecord::Migration
  def up
    rename_column :images, :imageable_id, :specimen_id
  end

  def down
    rename_column :images, :specimen_id, :imageable_id
  end
end
