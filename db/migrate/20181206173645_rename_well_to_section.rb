class RenameWellToSection < ActiveRecord::Migration
  def change
    rename_table :wells, :sections
    rename_column :samples, :well_id, :section_id
  end
end
