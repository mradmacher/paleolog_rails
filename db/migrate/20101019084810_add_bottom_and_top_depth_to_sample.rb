class AddBottomAndTopDepthToSample < ActiveRecord::Migration
  class Sample < ActiveRecord::Base
  end

  def self.up
    add_column :samples, :bottom_depth, :decimal
    add_column :samples, :top_depth, :decimal
    Sample.reset_column_information
    samples = Sample.all
    samples.each do |sample|
      sample.bottom_depth = sample.depth
      sample.top_depth = sample.depth
      sample.save
    end
    
    remove_column :samples, :depth
  end

  def self.down
    add_column :samples, :depth, :decimal

    Sample.reset_column_information
    samples = Sample.all
    samples.each do |sample|
      sample.depth = sample.bottom_depth
      sample.save
    end

    remove_column :samples, :top_depth
    remove_column :samples, :bottom_depth
  end
end
