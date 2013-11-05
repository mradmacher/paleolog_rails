class AddRegionToWell < ActiveRecord::Migration
	def self.up
		add_column :wells, :region_id, :integer
	end

	def self.down
		remove_column :wells, :region_id
	end
end
