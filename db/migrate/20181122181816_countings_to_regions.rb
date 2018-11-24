class CountingsToRegions < ActiveRecord::Migration
  def change
    add_column :countings, :region_id, :integer
    add_index :countings, :region_id

    countings = Counting.where('well_id IS NOT NULL').all.entries
    grouped_by_region = countings.group_by { |c| c.well.region_id }
    grouped_by_region.each do |region_id, region_countings|
      grouped_by_name = region_countings.group_by { |c| [c.name, c.marker_id].compact.join('-') }
      grouped_by_name.each do |name, name_countings|
        group_id = name_countings.first.group_id
        marker_id = name_countings.first.marker_id
        marker_count = name_countings.first.marker_count
        old_ids = name_countings.map(&:id)
        new_counting = Counting.where(region_id: region_id, name: name, marker_id: marker_id, marker_count: marker_count).first
        if new_counting.nil?
          new_counting = Counting.new(region_id: region_id, name: name, group_id: group_id, marker_id: marker_id, marker_count: marker_count)
          new_counting.save!
        end
        Occurrence.where(counting_id: old_ids).update_all(counting_id: new_counting.id)
      end
    end
  end
end
