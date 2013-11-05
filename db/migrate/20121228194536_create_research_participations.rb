class CreateResearchParticipations < ActiveRecord::Migration
  def change
    create_table :research_participations do |t|
      t.references :well
      t.references :user
      t.boolean :manager, :default => false

      t.timestamps
    end
  end
end
