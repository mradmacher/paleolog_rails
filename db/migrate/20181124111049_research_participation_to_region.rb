class ResearchParticipationToRegion < ActiveRecord::Migration
  def change
    add_column :research_participations, :region_id, :integer
    add_index :research_participations, :region_id
    remove_column :research_participations, :well_id
  end
end
