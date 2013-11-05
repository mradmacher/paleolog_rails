class AddCountingToOccurrences < ActiveRecord::Migration
  class Occurrence < ActiveRecord::Base
    set_table_name 'sample_specimens'
  end
  def self.up
    add_column :sample_specimens, :counting, :integer
    Occurrence.all.each do |occurrence|
      occurrence.counting = 1
      occurrence.save
    end
  end

  def self.down
    remove_column :sample_specimens, :counting
  end
end
