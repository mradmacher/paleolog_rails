class RenameRegionToProject < ActiveRecord::Migration
  def change
    rename_table :regions, :projects
    rename_column :countings, :region_id, :project_id
    rename_column :research_participations, :region_id, :project_id
    rename_column :sections, :region_id, :project_id
  end
end
